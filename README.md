# isc.json
Bleeding-edge JSON features, ahead of (but ultimately, in some form, destined for) the %JSON package in InterSystems IRIS Data Platform.

## Getting Started
Note: a minimum platform version of InterSystems IRIS 2018.1 is required.

### Installation: ZPM

If you already have the [ObjectScript Package Manager](https://openexchange.intersystems.com/package/ObjectScript-Package-Manager-2), installation is as easy as:
```
zpm "install isc.json"
```

## User Guide
See [isc.json User Guide](https://github.com/intersystems/isc-json/blob/master/docs/user-guide.md).

## Support
If you find a bug or would like to request an enhancement, [report an issue](https://github.com/intersystems/isc-json/issues/new). If you have a question, feel free to post it on the [InterSystems Developer Community](https://community.intersystems.com/).

## Contributing
Please read [contributing](https://github.com/intersystems/isc-json/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning
We use [SemVer](http://semver.org/) for versioning. Declare your dependencies using the community package manager for the appropriate level of risk.

## Authors
* **Tim Leavitt** - *Initial implementation* - [isc-tleavitt](http://github.com/isc-tleavitt)

See also the list of [contributors](https://github.com/intersystems/isc-json/graphs/contributors) who participated in this project.

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/intersystems/isc-json/blob/master/LICENSE) file for details.

## DOCKER Support
### Prerequisites   
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.    
### Installation    
Clone/git pull the repo into any local directory
```
$ git clone https://github.com/intersystems/isc-json.git  
```
Open the terminal in this directory and run:
```
$ docker-compose build
```
Run IRIS container with your project:
```
$ docker-compose up -d
```
Test from docker console
```
$ docker-compose exec iris1 iris session iris
USER>
```
or using **WebTerminal**
```
http://localhost:42773/terminal/
```  
