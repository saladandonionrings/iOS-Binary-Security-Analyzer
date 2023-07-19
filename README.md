# 🕵️‍♂️ iOS Binary Security Analyzer

This script inspects iOS binaries to uncover usage of **insecure functions**, **implementation of weak cryptography**, **encryption status**, and the presence of **security features** like *Position Independent Executable* (PIE), *Stack Canaries*, and *Automatic Reference Counting* (ARC). 

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

### 📸 Screenshot
![image](https://github.com/saladandonionrings/iOS-Binary-Security-Analyzer/assets/61053314/1f2ec322-c0da-4326-9f18-c1ad7585f6e7)


