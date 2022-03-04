.\build-site.ps1
Copy-Item -Path ./build/site/* -Destination ./docs/static/ -Force
Copy-Item -Path ./build/redoc/* -Destination ./docs/redoc/ -Force
