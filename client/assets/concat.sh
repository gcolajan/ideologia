#! /bin/bash

# With grunt soon
cd javascripts
cat tools/* > tools.concat.js
cat game/* > game.concat.js
cat app/main.js app/*/* > app.concat.js
rm ../phases/phases.concat.js
cat ../phases/*.js > ../phases/phases.concat.js
