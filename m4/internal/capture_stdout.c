/*
 * Copyright 2018 the rules_m4 authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
**/

#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <process.h>
#else
#include <unistd.h>
#endif

int main(int argc, char **argv) {
    int out_fd, rc;

    if (argc < 3) {
        fprintf(stderr, "%s: expected at least three arguments (got %d)\n", argv[0], argc);
        return 1;
    }

    out_fd = open(argv[1], O_CREAT | O_WRONLY, S_IREAD | S_IWRITE);
    if (out_fd == -1) {
        perror("open");
        return 1;
    }
    if ((rc = dup2(out_fd, 1)) == -1) {
        perror("dup2");
        return 1;
    }
    if ((rc = close(out_fd)) == -1) {
        perror("close");
        return 1;
    }
#ifdef _WIN32
    if ((rc = _spawnv(_P_WAIT, argv[2], argv + 2)) == -1) {
        perror("spawnv");
        return 1;
    }
    return 0;
#else
    if ((rc = execv(argv[2], argv + 2)) == -1) {
        perror("exec");
        return 1;
    }
    return 0; /* not reached */
#endif
}
