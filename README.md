# 🖥️ PowerShell

Most of these scripts will be adjusted/rewritten and used in the PowerModule application I am currently working on.

# 📜 Script Collection

Welcome to the **Script Collection** repository! This repo contains a variety of useful **PowerShell** and **CMD** scripts for different use cases, from automation to system administration.

## 📂 Repository Structure

The repository is organized as follows:
```
├── Root directory\ 
│ ├── .cmd
│ ├── .testing 
│ ├── automation project
│ ├── DC
│ | ├── Temp
│ | ├── testing
│ | | ├── BackupFolders
│ | | ├── DC
│ | | | └── .extra
│ | | ├── Lock Sensor
│ | | └── Obsolete Apps
│ | └── ...
| └── ...
├── README.md
├── ... 
├── ... 
└── ...
```

Each folder contains scripts categorized by their respective types (PowerShell or CMD).

## 🔧 Requirements

- **PowerShell scripts**: Require PowerShell 5.1 or higher. 🛠️
- **CMD scripts**: Run on any standard Command Prompt on Windows. 🖥️

## 📜 Available Scripts

### 💻 PowerShell
There are many PowerShell scripts available in this repository, each with different functionality and options. I have tried to keep everything as organized as possible, but will continue to clean up while working on everything.

### 🖥️ CMD
Most of the .cmd/batch files in this repository are used to call PowerShell scripts to then execute them. They are also very useful, and more will be added to the repository soon!

## 🚀 How to Use

### 💻 PowerShell
To run a PowerShell script, open PowerShell and use the following command:
```powershell
.\scriptname.ps1
```

*You may need to adjust the execution policy to allow script execution. Use the following command if necessary:*
```powershell
Set-ExecutionPolicy RemoteSigned
```

### 🖥️ CMD
To run a CMD script, open Command Prompt and use the following command:

```cmd
scriptname.bat
```

## 🛠️ Contributing
Feel free to contribute by adding your own scripts or improving existing ones. To contribute, follow these steps:

- Fork the repository 🍴
- Create a new branch (`git checkout -b feature/your-feature`) 🌿
- Commit your changes (`git commit -m 'Add some feature'`) 💬
- Push to the branch (`git push origin feature/your-feature`) 📤
- Open a pull request 🔄

## 🧰 Troubleshooting
If you run into any issues while using the scripts, here are a few common problems and solutions:

- **Execution Policy Errors (PowerShell)**: Ensure your execution policy allows running scripts by using `Set-ExecutionPolicy`. 🔧
- **File Permissions**: Make sure you have the required permissions to run the scripts, especially if running them on a work or shared system. 🔐
- **Syntax Errors**: Check for typos or missing characters in the script before running it. 📝

---

Enjoy using the scripts and happy scripting! 😊
