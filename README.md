# 🕵️‍♂️ iOS Binary Security Analyzer

This script inspects iOS application binaries to uncover usage of **insecure functions**, **implementation of weak cryptography**, **encryption status**, and the presence of **security features** like *Position Independent Executable* (PIE), *Stack Canaries*, and *Automatic Reference Counting* (ARC). 

## 🌟 Features
* Quick static analysis of iOS binaries
* Checks for various iOS binary security features (encryption, PIE, Stack Canaries, ARC)
* Detection of weak cryptographic methods (MD5, SHA1)
* Identification of commonly misused and insecure functions

## 📋 Requirements

1. 📲 **Jailbreak your iOS device.**
2. 🛠️ **Install otool:** *This can be done through the Cydia package manager*. 
   - Add the following repository in Cydia: `http://apt.thebigboss.org/repofiles/cydia/`
   - Search for and install the *Big Boss Recommended Tools* package.
   - Alternatively, search for and install the *Darwin CC Tools* package.
   - If your device is set up with SSH and command line access, you can also install otool via command line using: `apt install otool`

## 🚀 Usage 

The binary should be located within the `/private/var/containers/Bundle/Application/XXXXXXX/<APP-PATH>/` directory.

```bash
# on host
git clone https://github.com/saladandonionrings/ios-binary-checks.git
cd ios-binary-checks
# send the script to your ios device
scp check-binary.sh root@ip:/var/root

# on ios device
./check-binary.sh <binary>
```

### 📸 Screenshots
![image](https://github.com/saladandonionrings/iOS-Binary-Security-Analyzer/assets/61053314/17cb1aeb-a646-4249-9d0b-236f7f0a9b94)
![image](https://github.com/saladandonionrings/iOS-Binary-Security-Analyzer/assets/61053314/b3e8dcf3-4445-48b8-b3fd-017e7af23886)



