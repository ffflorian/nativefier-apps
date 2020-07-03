# nativefier-apps

Create Linux apps with [nativefier](https://www.npmjs.com/package/nativefier).

## Prerequisites

- Linux
- bash
- a fairly new version of npm (>= v5.2.0)

## Usage

1. Clone this repository or [download](https://github.com/ffflorian/nativefier-apps/archive/main.zip) it
2. Run `nativefier.sh` or one of the app scripts


## Example

```
$ ./nativefier.sh --help
Usage: nativefier.sh [options] <switches>

Switches:
 --logo        (-l)     App logo (png file, e.g. "./my-app.png")
 --name        (-n)     App name (e.g. "MyApp")
 --short-name  (-s)     Short app name (e.g. "my-app")
 --url         (-u)     App URL without protocol (e.g. "web.my-app.com")

Options:
 --force       (-f)     Force overwriting existing installations (default is false)
 --install-dir (-i)     App installation dir (default is "/opt/<my-app>")

Commands:
 --help        (-h)     Display this help message

$ ./nativefier.sh -l "./logos/gmail.png" -s "gmail" -n "Google Mail" -u "mail.google.com"
Building Google Mail for Linux ...
Checking existing Google Mail installations ...
Creating app ...
  packaging [==============================                    ] 60%
  Packaging app for platform linux x64 using electron v5.0.10
Copying app to "/opt/gmail" ...
[sudo] password for florian:
Creating desktop entry ...
Done.
```
