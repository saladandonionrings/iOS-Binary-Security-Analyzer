# 🕵️‍♂️ iOS Binary Security Analyzer

This script inspects iOS application binaries to uncover usage of **insecure functions**, **implementation of weak cryptography**, **encryption status**, **code signature** and the presence of **security features** like *Position Independent Executable* (PIE), *Stack Canaries*, and *Automatic Reference Counting* (ARC). It also performs checks on **Dynamic Library dependencies**, and potential **anti-analysis/debugging** symbols.

## 🌟 Features
* Quick static analysis of iOS binaries.
* Checks for core binary security mitigations (Encryption, Code Signature, PIE, Stack Canaries, ARC).
* Detection of weak cryptographic methods (MD5, SHA1).
* Identification of commonly misused and insecure C functions.
* Analysis of Dynamic Library dependencies (otool -L) to spot potential vulnerable frameworks.
* Detection of debugging and anti-analysis symbols (e.g., ptrace, fork).

## 📋 Requirements

1. 📲 **Jailbreak your iOS device.** : rootfull or rootless
2. 🛠️ **Install otool:** *This can be done through the Cydia package manager*. 
   - Add the following repository in Cydia: `http://apt.thebigboss.org/repofiles/cydia/`
   - Search for and install the *Big Boss Recommended Tools* package.
   - Alternatively, search for and install the *Darwin CC Tools* package.
   - If your device is set up with SSH and command line access, you can also install otool via command line using: `apt install otool`

## 🚀 Usage 

>The binary should be located within the `/private/var/containers/Bundle/Application/XXXXXXX/<APP-PATH>/` directory.
>Or in `/var/containers/Bundle/Application/XXXXXXX/<APP-PATH>/` if installed with TrollStore.

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
<img width="1397" height="946" alt="checkbinary1" src="https://github.com/user-attachments/assets/9a425cc9-94d3-4246-b8dd-114108c87ca8" />
<img width="990" height="874" alt="checkbinary2" src="https://github.com/user-attachments/assets/45c35458-9b2a-47fa-9716-0e1b31d71a31" />
<img width="1049" height="949" alt="checkbinary3" src="https://github.com/user-attachments/assets/11cb1495-355f-4405-97fd-a235ae1a62e7" />
<img width="1331" height="1022" alt="checkbinary4" src="https://github.com/user-attachments/assets/648feead-f120-4711-adb4-70d98b48628d" />







