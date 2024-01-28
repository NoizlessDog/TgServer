FROM alpine:latest

# Environment Variables
ENV GODOT_VERSION "3.5.3"
ENV GODOT_EXPORT_PRESET="Linux/X11"
ENV GODOT_GAME_NAME "Server"
ENV HTTPS_GIT_REPO "https://github.com/NoizlessDog/TgServer.git"

# Updates and installs to the server
RUN apk update
RUN apk add --no-cache bash
RUN apk add --no-cache wget
RUN apk add --no-cache git

# Allow this to run Godot
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
RUN apk add gcompat
RUN apk add --force-overwrite --allow-untrusted glibc-2.35-r0.apk

# Download Godot and export template, version is set from variables
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

# Make needed directories for container
RUN mkdir /godotapp

# Move to the build space and export the .pck
RUN git clone ${HTTPS_GIT_REPO}
WORKDIR /TgServer
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN git pull
RUN mv ${GODOT_GAME_NAME}.pck /godotapp/

# Change to the godotapp space, delete the source,  and run the app
WORKDIR /godotapp
run rm -f -R /godotbuildspace
CMD godot --main-pack ${GODOT_GAME_NAME}.pck
