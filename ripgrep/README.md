# Ripgrep

I only use ripgrep (**rg**) as the FZF default command with some flags.

## Configuration Files

It basically exists 2 configuration files. The __.ripgreprc__ is really a configuration file. The __.ripgrepignore__ is more of a convenience file.

### .ripgreprc

I have a system environment variable that points to this file as being the ripgrep default configuration behavior. This means that every time I run the **rg** command, it will behave as defined in this file. So I have to be careful.

### .ripgrepignore

I use this file alongside the FZF default command. It basically has some directories and files to ignore when searching for something. Putting things here is more granular than defining a genric behavior for **rg**.
