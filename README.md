# HelloID-Conn-Prov-Source-Isah

| :warning: Warning |
|:---------------------------|
| Isah uses a generic export definition that is delta-based. Since HelloID requires a full data export, the customer will need to implement a middleware layer. Consequently, this connector will not work out of the box   |

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/isah-logo.png" alt="Isah logo">
</p>

<!-- TABLE OF CONTENTS -->
## Table of Contents

- [HelloID-Conn-Prov-Source-Isah](#helloid-conn-prov-source-isah)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting Started](#getting-started)
  - [Remarks](#remarks)
  - [Getting help](#getting-help)
  - [HelloID Docs](#helloid-docs)

## Introduction

This connector imports JSON-files generated in Isah to HelloID.

## Getting Started

By using this connector you will have the ability to retrieve employee and contract data from the Isah system.

### Connection settings

As this connector is created for one implementation, it's possible these settings have to be changed.

| Setting         | Description                                   | Mandatory   |
| --------------- | --------------------------------------------- | ----------- |
| JSON Netherlands Path         | The full path of the json file for this Isah database | Yes         |
| JSON Malaysia Path          | The full path of the json file for this Isah database | Yes         |
| JSON Singapore Path | The full path of the json file for this Isah database | Yes         | 

### Prerequisites

- [ ] HelloID Provisioning agent (on-prem).
- [ ] Scheduled exports of personel data in JSON format from Isah.

## Remarks

- This connector is tailor made and based on a export a customer provided. The connector will need to be modified to support other implementations.
- The connector creates extra contracts in HelloID based on the definition of optional 'RBAC roles'. Each defined RBAC role is assigned its own contract.
- If the EndDate of role is later than the actual enddate of the contract, the connector sets the enddate of the role to the enddate of the contract.

### Mappings
A mapping export is provided. Make sure to further customize these accordingly.

## Getting help
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012558020-Configure-a-custom-PowerShell-target-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID docs
The official HelloID documentation can be found at: https://docs.helloid.com/
