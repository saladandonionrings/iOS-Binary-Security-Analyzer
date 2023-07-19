# 🕵️‍♂️ iOS Binary Insecure Functions Checker

This script checks an iOS binary for the **presence of certain potentially insecure function calls**. The script is intended to be run on a jailbroken iOS device and requires the `otool` command to function.

## 📋 Requirements

1. 📲 **Jailbreak your iOS device.**
2. 🛠️ **Install otool:** *This can be done through the Cydia package manager*. 
   - Add the following repository in Cydia: `http://apt.thebigboss.org/repofiles/cydia/`
   - Search for and install the *Big Boss Recommended Tools* package.
   - Alternatively, search for and install the *Darwin CC Tools* package.
   - If your device is set up with SSH and command line access, you can also install otool via command line using: `apt install otool`

## 🚀 Usage 

The binary should be located within the `/private/var/containers/Bundle/Application/XXXXXXX/<APP-PATH>/` directory.

**Run the script :**

```bash
./check-binary.sh <binary>
```
