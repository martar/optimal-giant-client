# OptimalGiant client

Client side code for in browser computations and visualization

## Dependency

In order to build the project, you will need brunch.io https://github.com/brunch/brunch

## Getting started

After cloning the repo, enter the project directory for the first time and type 'npm install'
In order to build the project type: ./build.sh

in order to launch the server type: brunch watch --server

## What's going on

So far, on page load, the web worker is started and she computes one step in our model simulation. Return value is prointed to the browser's console