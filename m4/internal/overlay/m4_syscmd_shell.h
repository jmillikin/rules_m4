#include <stdlib.h>

/* Allow SYSCMD_SHELL to be injected at runtime, for users that don't
 * want arbitrary code execution in their template expansions.
**/
#define SYSCMD_SHELL m4_syscmd_shell()

static inline const char* m4_syscmd_shell() {
    const char *from_env = getenv("M4_SYSCMD_SHELL");
    if (from_env) { return from_env; }
    return "/bin/sh";
}
