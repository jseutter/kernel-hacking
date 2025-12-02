#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include "helpers.h"

static int __init multi_hello_init(void)
{
    helper_function_say_hello();
    printk(KERN_INFO "Multi_Hello Module: Initialization complete.\n");
    return 0;
}

static void __exit multi_hello_exit(void)
{
    printk(KERN_INFO "Multi_Hello Module: Goodbye from the file-1.c.\n");
}

module_init(multi_hello_init);
module_exit(multi_hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Me (and Gemini)");
MODULE_DESCRIPTION("A multi-file kernel module demonstrating Kbuild linking.");

