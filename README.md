# OptimalGiant client

Client side code for in browser computations and visualization

## Dependency

In order to build the project, you will need brunch.io https://github.com/brunch/brunch

## Getting started

After cloning the repo, enter the project directory for the first time and type: 

    npm install

In order to build the project type: 

    ./build.sh

in order to launch the server type:

    brunch watch --server

You're done. To 'see' the effect navigate to your browser to http://localhost:3333

## What's going on

As for now, the only interesting part of the code is placed in 
worker/ directory. Anything besides it is a boilerplate.

On page load, the web worker is started and she computes one step in our model simulation. Return value is printed to the browser's console