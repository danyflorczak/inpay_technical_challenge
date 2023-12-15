# How-to use asdf

This guide shows you how to use [asdf](https://asdf-vm.com)

## Install `asdf`

The best is to follow [official docs](https://asdf-vm.com/guide/getting-started.html)

## Install plugins

First check `.tool-versions` then, usually run `asdf plugin-add NAME`
When plugins are installed, you can install the tools by running `asdf install`

## Usage

When `asdf` is installed in the system, and the project has `.tool-versions` configured, asdf is taking care of changing tools when switching from one project directory to another. In case of changes in `.tool-versions` or missing tools simply run `asdf install` and after a while, you are ready to go.
