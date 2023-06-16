# REDCap on Azure
Inspired by https://github.com/microsoft/azure-redcap-paas/tree/main

## Usage

1. Open this repository in a devcontainer
2. Create a `.env` file from `.env.sample` replacing the values where appropriate 
3. Download the REDCap source as a `.zip` file into [redcap_app](./redcap_app/)
4. Run
```
make login
made deploy
# make destroy
```
