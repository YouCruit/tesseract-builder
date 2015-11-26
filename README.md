# Tesseract Builder
### Purpose

This package downloads, builds tesseract and it's dependencies in a way suitable for distribution in a Heroku slug.

### Building
It is highly recommended that the build is done in a docker for reproducability. Installing java and maven is beyond the scope of this minimal documentation, but once that is taken care of, run:
```
root@xxxxxxxxxxxx:/tesseract-builder# apt-get install -y zlib1g-dev libpng-dev libgif-dev libtiff-dev libwebp-dev libopenjp2-7-dev libjpeg-dev build-essential
root@xxxxxxxxxxxx:/tesseract-builder# mvn clean install
```
