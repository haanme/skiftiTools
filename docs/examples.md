# Examples
## _The Last Markdown Editor, Ever_


Dillinger is a cloud-enabled, mobile-ready, offline-storage compatible,
AngularJS-powered HTML5 Markdown editor.

- Type some Markdown on the left
- See HTML in the right
- ✨Magic ✨

## Example 1:

Principal component analysis:

Using together with ants TBSS toolbox:
- 1.1 Align data to ENIGMA [1] template using ants TBSS package [2]:
- 1.1.0 Do DTI preprocessing e. g.
- 1.1.1 Place FA scalar maps into output folder (after this assuming that the FA maps are with .nii.gz suffix in subfolder called ‘output’)
- 1.1.2 Create list of subject names to run e. g. :
```sh
$ for f $(ls output); do echo $($f | awk -F’. ‘{print $1}’); done > caselist.txt
```  
- 1.1.3 Run ants TBSS with docker to create TBSS results to subfolder ‘out’:
```sh
$ docker run -it –rm haanme/ants_tbss:0.4.2 -i $(pwd)/tractoinferno_FA -c caselist.txt –modality FA –enigma -o $(pwd)/out
```

- 1.1.4 Run ants TBSS with docker to create TBSS results to subfolder ‘out’:


[1] https://enigma.ini.usc.edu/protocols/dti-protocols/ [2] https://github.com/trislett/ants_tbss

## Example 2:



## Installation: Github


https://github.com/haanme/skiftiTools

## Installation: Docker in lifespan project

skiftiTools is very easy to install and deploy in a Docker container, 
we have built docker container that creater skifti data from TBSS output
```sh
docker run -v $(pwd):/data -it haanme/lifespan_postprocess:0.2.3 --name TESTSITE --path /data --outputpath /data/out_ants_tbss_postprocess_output --TBSSsubfolder out_docker
```

## Installation: RStudio

<UNDER CONSTRUCTION>
