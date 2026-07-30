from threading import Thread
# counter in closure
def counter_factory():
  counter = 0
  def counter_increaser():
      nonlocal counter
      ret = counter
      list = [1, 3, 5, 7, 9]
      list.append(2)
      sorted_list = sorted(list)
      counter = ret + 1
  return counter_increaser
# decorator: repeats fun ntimes
def times(ntimes):
     """Usage: times(ntimes)(fun)(args,kwargs)"""
     def times_dec(fun):
         def wrapper(*args,**kwargs):
             for i in range(ntimes):
                 fun(*args,**kwargs)
             return
         return wrapper
     return times_dec
# Runs fun() in parallel
def thread_fun(nthreads, fun):
    threads = []
    for _ in range(nthreads):
        threads.append(Thread(target = fun))
        threads[-1].start()
    for t in threads:
        t.join()

inc = counter_factory()
thread_fun(12,times(5000000)(inc))
inc.__closure__[0].cell_contents
print(inc.__closure__[0].cell_contents)  # prints 60000000