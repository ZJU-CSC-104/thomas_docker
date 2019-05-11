#!/usr/bin/env zsh

# Create user
if [ -n "${DOCKER_USER}" ] && [ -n "${DOCKER_USER_ID}" ] && [ -n "${DOCKER_GRP}" ] && [ -n "${DOCKER_GRP_ID}" ]; then

  # Add group & user
  addgroup --gid ${DOCKER_GRP_ID} ${DOCKER_GRP}
  adduser --disabled-password --gecos '' --uid ${DOCKER_USER_ID} ${DOCKER_USER} --ingroup ${DOCKER_GRP} --home /home/${DOCKER_USER}
  usermod -aG sudo "$DOCKER_USER"
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

  # Add user to pointgrey group
  if [ -n "${PG_GRP}" ]; then
    addgroup --gid ${PG_GRP_ID} ${PG_GRP}
    usermod -aG ${PG_GRP} "${DOCKER_USER}"
  fi

  # zsh & bash related
  sed "s/root/home\/${DOCKER_USER}/" ~/.zshrc > /home/${DOCKER_USER}/.zshrc
  cp -r ~/.oh-my-zsh /home/${DOCKER_USER}
  cp ~/.bashrc /home/${DOCKER_USER}

  # ROS related
  mkdir /home/${DOCKER_USER}/.ros
  cp -r ~/.ros/rosdep /home/${DOCKER_USER}/.ros

  # VNC related
  if [ -d /root/.vnc ]; then
    cp -r /root/.vnc /home/${DOCKER_USER}/
  fi

  # OS specific configuration
  if [ $(uname) = 'Darwin' ]; then
    chmod a+rwx /dev/null
    chmod a+rwx /dev/urandom
  fi

  # Finalize
  chown -R ${DOCKER_USER}:${DOCKER_GRP} /home/${DOCKER_USER}

fi
