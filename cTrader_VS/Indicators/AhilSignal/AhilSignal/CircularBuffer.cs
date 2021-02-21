using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace cAlgo
{
    public class CircularBuffer<T>
    {
        private T[] buffer;
        private int nextFree;
        public bool IsPrimed { get; private set; }
        private int length;
        public int last, previous;

        public CircularBuffer(int length)
        {
            buffer = new T[length];
            nextFree = 0;
            IsPrimed = false;
            this.length = length;
            this.last = 0;
            this.previous = 0;
        }

        public void Add(T o)
        {
            buffer[nextFree] = o;
            previous = last;
            last = nextFree;
            nextFree = (nextFree + 1) % buffer.Length;
            if (nextFree == length) IsPrimed = true;
        }
        
        public T GetLast()
        {
            return buffer[last];
        }

        public T GetPrevious()
        {
            return buffer[previous];
        }

        public T GetMax()
        {
            return buffer.Max();
        }
    }
}
