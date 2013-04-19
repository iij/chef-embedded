# chef-embedded

Chef build script for embedded systems.

## What's chef-embedded
chef-embedded is a collection of scripts which build chef and other
necessary packages such as toolchain, ruby, gems.

## How to get chef-embedded
The chef-embedded distribution files can be found in the following site:

  https://github.com/iij/chef-embedded/zipball/master

The trunk of the chef-embedded source tree can be checked out with the
following command:

    $ git clone https://github.com/iij/chef-embedded.git

There are some other branches under development. Try the following
command and see the list of branches:

    $ git branch -r

## chef-embedded home-page

chef-embedded's website is not launched yet but we are actively working on it.

The URL of the chef-embedded home-page will be:

  https://github.com/iij/chef-embedded/wiki

## How to build

First, copy amples/localrc to top-directory of source code, and edit it.

Then, execute a script 'build.sh'

  ./build.sh

If build is successful, you can find tarball in build/chef-embedded-(ver).tar.bz2

## License

chef-embedded is subject to this license:

/*-
 * Copyright (c) 2013, Internet Initiative Japan Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

## How to Contribute
Contributions are Welcome!
