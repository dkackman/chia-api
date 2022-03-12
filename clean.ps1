param(
    $folder
)

if (!$folder) {
    $folder = "./build"
}

if (Test-Path $folder) {
    Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
}