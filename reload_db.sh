#!/bin/bash
be='bundle exec'
$be rake db:drop && $be rake db:create && $be rake db:migrate && $be rake db:seed
