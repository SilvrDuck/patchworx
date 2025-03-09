#include "services/ctest/ctest.pb.h"
#include <iostream>

int main()
{
    // Using the generated protobuf code
    example::Potato potato;
    potato.set_name("Russet");
    potato.set_age(43);

    std::cout << "Potato name: " << potato.name() << std::endl;
    std::cout << "Potato age: " << potato.age() << std::endl;

    return 0;
}