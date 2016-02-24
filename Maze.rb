require 'set'

#Xingyu Lu
#Maze

#this class represents a cell in the maze
class Point
  attr_reader :x, :y, :prev
  #this cell contains its coordinates and its previous cell in the route
  def initialize(x,y)
    @x = x
    @y = y
    @prev = nil
  end

  def setPrev(p)
    @prev = p
  end

  def to_S
    "(#{x}, #{y})"
  end

  #test if this cell is the destination
  def isEqual(p)
    (p.x == x) && (p.y == y)
  end
end



class Maze
  #create a new maze, initialized as a hash(2D array)
  def initialize(n,m)
    #according to the input dimensions, create a hash containing 2m+1 keys with value as
    #an array of size 2n+1. This hash actually stores the walls
    @mat = Hash.new
    for i in 0..2*m
      @mat[i] = Array.new(2*n+1)
    end
    #this node is for tracing the path
    @tnode = nil
  end

  #take in the string consisting of 1 and 0 and put them into the hash
  def load(arg)
    index = 0
    @mat.each do |key,row|
      (0..row.length-1).each do |i|
        row[i] = arg[index]
        index += 1
      end
    end
  end

  #output the contents stored in the hash
  def display
    @mat.each do |key,row|
      row.each do |ele|
        if ele == "1"
          print ele
        else
          print " "
        end
      end
      puts "\n"
    end
  end

  #slove the maze according to the starting point and destination
  def solve(begX, begY, endX, endY)
    #first create two points object as starting point and destination
    start = Point.new(begX,begY)
    final = Point.new(endX,endY)

    if start.isEqual(final)
      @tnode = start
      true
    else
      #keep track of the cells we have been to
      traceSet = Set.new
      #keep track of the cells which may lead to a possible solution
      traceArray = Array.new
      #put the starting cell into the set and array
      traceSet.add(start.to_S)
      traceArray.push(start)

      #start sloving
      newp = traceArray.shift
      #we don't stop until all the possible pathes are tested

      while newp != nil do
        #test each route and if we reach the destination, immediately break
        #the while loop

        #test if we can move upward
        if @mat[2*newp.y][2*newp.x+1] == "0"
          up = Point.new(newp.x,newp.y-1)
          move(up,newp,traceArray,traceSet)
          if up.isEqual(final)
            newp = up
            break
          end
        end

        #test if we can move downward
        if @mat[2*newp.y+2][2*newp.x+1] == "0"
          down = Point.new(newp.x,newp.y+1)
          move(down,newp,traceArray,traceSet)
          if down.isEqual(final)
            newp = down
            break
          end
        end

        #test if we can move leftward
        if @mat[2*newp.y+1][2*newp.x] == "0"
          left = Point.new(newp.x-1,newp.y)
          move(left,newp,traceArray,traceSet)
          if left.isEqual(final)
            newp = left
            break
          end
        end


        #test if we can move rightward
        if @mat[2*newp.y+1][2*newp.x+2] == "0"
          right = Point.new(newp.x+1,newp.y)
          move(right,newp,traceArray,traceSet)
          if right.isEqual(final)
            newp = right
            break
          end
        end

        #move to the next cell
        newp = traceArray.shift
      end

      #if the current cell is nil, it means we have no solution for this maze puzzle
      if newp == nil
        false
      else   #else we set @tnode as the current cell
        @tnode = newp
        true
      end
    end
  end

  #if we can move to the point in the argument and we have never been to this point, we set this point's previous as the
  #current cell and put this cell in the array and set
  def move(point,prev,queue,set)
    if !(set.include?(point.to_S))
      point.setPrev(prev)
      queue.push(point)
      set.add(point.to_S)
    end
  end

  #if this puzzle can be solved, we print out the path by backtracking through the last cell
  #if not, just print out the error message
  def trace(begX, begY, endX, endY)
    if solve(begX, begY, endX, endY)
      node = @tnode
      trace = Array.new
      while node != nil do
        trace.unshift(node.to_S)
        node = node.prev
      end

      trace.each do |elem|
        print elem, " "
      end
      print "\n"
    else
      puts "Error! No solution exists."
    end
  end

  #first empty the maze, that is to set every element as 0 except the outside walls
  #then use a recursive algorithm to generate a new maze
  def redesign
    r = Random.new
    x = @mat[0].length
    y = @mat.size
    (1..y-2).each do |i|
      (1..x-2).each do |j|
        @mat[i][j] = "0"
      end
    end

    divide(1,x-2,1,y-2,r)
  end

  #use recursion to generate a new maze
  #each iteration will create a new wall with one gap in it.
  #then the division is in the two sides of the wall just created
  #the resursion stops when the length or width of the current division is 1
  def divide(x1,x2,y1,y2,r)
    width = x2-x1+1
    length = y2-y1+1
    if length != 1 && width != 1
      if length > width    #add walls horizontally
        div = r.rand(y1..y2)
        while div%2 == 1 do
          div = r.rand(y1..y2)
        end

        (x1..x2).each do |i|
          @mat[div][i] = "1"
        end

        #set a gap between the walls
        gap = r.rand(x1..x2)
        while gap%2 == 0 do
          gap = r.rand(x1..x2)
        end

        @mat[div][gap] = "0"
        divide(x1,x2,y1,div-1,r)
        divide(x1,x2,div+1,y2,r)
      else                #add walls vertically
        div = r.rand(x1..x2)
        while div%2 == 1 do
          div = r.rand(x1..x2)
        end

        (y1..y2).each do |i|
          @mat[i][div] = "1"
        end

        #set a gap between walls
        gap = r.rand(y1..y2)
        while gap%2 == 0 do
          gap = r.rand(y1..y2)
        end

        @mat[gap][div] = "0"
        divide(x1,div-1,y1,y2,r)
        divide(div+1,x2,y1,y2,r)
      end
    end
  end
end
