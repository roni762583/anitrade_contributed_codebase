using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace cAlgo
{
    public class CircularBuffer<T>
    {
        T[] buffer;
        int nextFree;

        public CircularBuffer(int length)
        {
            buffer = new T[length];
            nextFree = 0;
        }

        public void Add(T o)
        {
            buffer[nextFree] = o;
            nextFree = (nextFree + 1) % buffer.Length;
        }
    }

}