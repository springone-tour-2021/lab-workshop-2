#! /bin/bash

echo 'Uninstalling VS Code extensions...'

EXT_DIR='/opt/code-server/extensions'

code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension golang.go
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension humao.rest-client
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension ms-kubernetes-tools.vscode-kubernetes-tools
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension ms-python.python
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension Pivotal.vscode-spring-boot
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension redhat.vscode-xml
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension redhat.vscode-yaml
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension vscjava.vscode-java-test
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension vscjava.vscode-java-debug
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension vscjava.vscode-java-dependency
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension vscjava.vscode-maven
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension vscjava.vscode-spring-initializr
code-server --extra-extensions-dir "$EXT_DIR" --uninstall-extension redhat.java

echo 'Removing extension folders since code-server does not clean-up properly...'

find "$EXT_DIR" -type d -name 'golang.go-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'humao.rest-client-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'ms-kubernetes-tools.vscode-kubernetes-tools-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'ms-python.python-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'pivotal.vscode-spring-boot-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'redhat.vscode-xml-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'redhat.vscode-yaml-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'vscjava.vscode-java-test-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'vscjava.vscode-java-debug-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'vscjava.vscode-java-dependency-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'vscjava.vscode-maven-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'vscjava.vscode-spring-initializr-*' -exec rm -r {} +
find "$EXT_DIR" -type d -name 'redhat.java-*' -exec rm -r {} +
