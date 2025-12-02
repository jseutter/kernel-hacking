#include <linux/kernel.h>
#include "helpers.h"


void helper_function_say_hello(void)
{
	pr_info("Helper function: hello from file-2.c\n");
}
