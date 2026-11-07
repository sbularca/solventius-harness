& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $repo = 'sbularca/solventius-harness'
    $dir = if ($env:SOLV_INSTALL_DIR) { $env:SOLV_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'solv' }
    $system = 'windows-x64'

    if (-not [Environment]::Is64BitOperatingSystem) {
        Write-Host 'error: solv needs 64-bit Windows.' -ForegroundColor Red
        return
    }

    $tag = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name
    $version = $tag.TrimStart('v')
    $name = "solventius-harness-$version-$system"
    $base = "https://github.com/$repo/releases/download/$tag"

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory $tmp | Out-Null
    try {
        Write-Host "Downloading $name.zip"
        $zip = Join-Path $tmp "$name.zip"
        Invoke-WebRequest "$base/$name.zip" -OutFile $zip -UseBasicParsing
        $sums = (Invoke-WebRequest "$base/SHA256SUMS" -UseBasicParsing).Content
        if ($sums -is [byte[]]) { $sums = [Text.Encoding]::UTF8.GetString($sums) }

        $line = $sums -split "`n" | Where-Object { $_.Trim().EndsWith(" $name.zip") } | Select-Object -First 1
        if (-not $line) {
            Write-Host "error: $name.zip is not in SHA256SUMS" -ForegroundColor Red
            return
        }
        $expected = ($line -split ' ')[0]
        if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $expected) {
            Write-Host "error: checksum mismatch for $name.zip" -ForegroundColor Red
            return
        }

        $exe = Join-Path $dir 'solv.exe'
        $running = Get-Process solv -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe }
        if ($running) {
            Write-Host 'error: solv is running. Close it and run this again.' -ForegroundColor Red
            return
        }

        Expand-Archive $zip (Join-Path $tmp 'unpacked')
        New-Item -ItemType Directory -Force $dir | Out-Null
        Get-ChildItem (Join-Path $tmp "unpacked\$name") -File | Copy-Item -Destination $dir -Force
        Unblock-File $exe
    } finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }

    & $exe --selftest *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'Self-test passed.'
    } else {
        Write-Host "warning: the self-test failed. Run '$exe --selftest' to see why." -ForegroundColor Yellow
    }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($userPath -split ';' | Where-Object { $_ })
    if ($parts -notcontains $dir) {
        [Environment]::SetEnvironmentVariable('Path', (($parts + $dir) -join ';'), 'User')
        Write-Host "Added $dir to your PATH."
    }
    if (($env:Path -split ';') -notcontains $dir) { $env:Path = "$env:Path;$dir" }

    Write-Host "Installed solv $version in $dir"
    Write-Host 'Run: solv --help'
}
