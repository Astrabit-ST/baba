#include <iostream>

template <typename T>
void Literal<T>::print()
{
    std::cout << val;
}
