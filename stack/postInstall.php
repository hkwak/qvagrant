<?php

echo 'Post Install'.PHP_EOL;

copy(__DIR__.'/../Vagrantfile', __DIR__.'/../../../Vagrantfile');

echo 'Copied Vagrant file'.PHP_EOL;
