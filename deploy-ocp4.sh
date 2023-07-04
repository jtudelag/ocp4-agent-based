#!/bin/bash

sudo cp agent/agent.x86_64.iso /var/lib/libvirt/images/

kcli create plan -f kcli-plans/sno-connected-plan.yaml
