#
# author: Noah Rossignol
# version: 1.4.1
# date: 08/06/2015
#
# modifed by: Rowan Walsh
# date: 2017-12-21
#
# Copyright (c) 2015, Noah Rossignol
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


class vector(tuple):
    '''vector(iterable) -> new vector initialized from iterable's items

    A vector here is represented by its components in Cartesian 
    coordinates.  A vector can be in any number of dimensions.'''
    def __add__(self,other):
        '''x.__add__(y) <==> x+y vector addition'''
        if len(self) == len(other):
            v=[]
            for i in range(len(self)):
                v.append(self[i]+other[i])
            return vector(v)
        else:
            raise ValueError("Cannot add vectors of different size")

    def __mul__(self,num):
        '''x.__mul__(c) <==> x*c scalar multiplication of vector.
        c is expected to be a scalar, e.g. int or float'''
        v=[]
        for i in range(len(self)):
            v.append(self[i]*num)
        return vector(v)

    def __rmul__(self,num):
        '''x.__rmul__(c) <==> c*x'''
        return self*num

    def __sub__(self,other):
        '''x.__sub__(y) <==> x-y vector subtraction.'''
        return self+(other*-1)

    def __div__(self,num):
        '''x.__div__(c) <==> (1.0/c)*x'''
        return (1.0/num)*self

    def __floordiv__(self,num):
        '''x.__floordiv__(c) <==> x//c'''
        l1=[]
        for e in self:
            l1.append(e//num)
        return vector(l1)

    def __pow__(self,p):
        '''x.__pow__(c) <==> x.^c'''
        l1=[]
        for e in self:
            l1.append(e**p)
        return vector(l1)

    def getLength(self):
        '''Returns the Euclidian norm of the vector (Pythagorean formula)'''
        return norm(self)

    def getSize(self):
        '''Returns the size of the vector'''
        return len(self)


class matrix(tuple):
    '''matrix(iterable) -> initializes a matrix based on the given iterable,
    which is expected to contain iterables.
    A matrix is a two dimensional collection.  It is indexed by:
    x[row][column]'''

    def __new__(cls, t):
        '''It is easy to enter a new matrix in the following format:
        >>>x=matrix((
        (r0c0, r0c1, r0c2),
        (r1c0, r1c1, r1c2),
        (r2c0, r2c1, r2c2)
        ))
        (the matrix can have any number of rows and columns)'''
        temp=[]
        for row in t:
            if len(row)==len(t[0]):
                temp.append(tuple(row))
            else:
                raise ValueError("Rows are of different lengths.")
        return tuple.__new__(cls, tuple(temp))

    def __str__(self):
        '''Prints the matrix in an easy to read format.
        x.__str__() <==> str(x)'''
        s2=""
        for row in self:
            s1='('
            for ele in row:
                s1+=" {0:^7g} ".format(ele)
            s1+=')'
            s2+=(s1+"\n")
        return s2

    def __add__(self, other):
        '''x.__add__(y) <==> x+y  is not concatenation.'''
        l1=[]
        for i in range(len(self)):
            ltemp=[]
            for j in range(len(self[0])):
                ltemp.append(self[i][j]+other[i][j])
            l1.append(tuple(ltemp))
        return matrix(tuple(l1))

    def __mul__(self, scal):
        '''x.__mul__(y) <==> x*y '''
        l1=[]
        for i in range(len(self)):
            ltemp=[]
            for j in range(len(self[0])):
                ltemp.append(scal*self[i][j])
            l1.append(tuple(ltemp))
        return matrix(tuple(l1))

    def __rmul__(self, scal):
        '''x.__rmul__(y) <==> y*x '''
        return self*scal

    def __sub__(self, other):
        '''x.__sub__(y) <==> x-y '''
        return self + (-1*other)

    def __div__(self,c):
        '''x.__div__(c) <==> (1.0/c)*x'''
        return (1.0/c)*self

    def __floordiv__(self,c):
        '''x.__floordiv__(c) <==> x//c'''
        outer=[]
        for i in self:
            inner=[]
            for j in i:
                inner.append(j//c)
            outer.append(inner)
        return matrix(outer)

    def __pow__(self,p):
        '''x.__pow__(p) <==> x.^p'''
        outer=[]
        for i in self:
            inner=[]
            for j in i:
                inner.append(j**p)
            outer.append(inner)
        return matrix(outer)

    def generateRows(self):
        '''A generator which yields the rows of the matrix as vectors.'''
        for row in self:
            yield vector(row)

    def generateCols(self):
        '''A generator which yields the columns of the matrix as vectors'''
        for i in range(len(self[0])):
            l1=[]
            for row in self:
                l1.append(row[i])
            yield(vector(l1))

    def rcGenerator(self):
        '''A generator which yields all of the elements of the matrix 
        going across each row first.  It is a breadth first generator.'''
        for row in self:
            for e in row:
                yield(e)

    def crGenerator(self):
        '''A generator which yields all of the elements of the matrix
        going down each column first.  It is a depth first generator.'''
        for i in range(len(self[0])):
            for row in self:
                yield(row[i])


# Functions

def zeroVector(l):
    '''Makes a zero vector of size l.'''
    res=[]
    for i in range(l):
        res.append(0)
    return vector(res)


def onesVector(l):
    '''Makes a ones vector of size l.'''
    res=[]
    for i in range(l):
        res.append(1)
    return vector(res)


def zeroMatrix(m,n):
    '''Constructs a matrix with m rows and n columns which contains
    zeroes.'''
    return matrix([zeroVector(n) for i in range(m)])


def identityMatrix(n):
    '''Constructs an identity matrix with n rows and n columns.'''
    res=[]
    for i in range(n):
        res.append(unitVector(i,n))
    return matrix(res)


def unitVector(i,dim):
    '''Makes a unit vector with a one at the i-th index and zeros for
    all others.  It is of size dim.'''
    if(i>=dim or i<0):
        raise IndexError("Index out of range.  Indexing goes from 0 to dim-1")
    v1=[]
    for j in range(dim):
        if j==i:
            v1.append(1)
        else:
            v1.append(0)
    return vector(v1)


def v(*args):
    '''Wrapper function around vector instantiation.  Returns a vector
    whose elements are the given args.'''
    return vector(args)


def transpose(m1):
    '''Returns a matrix which is the transpose of the given two dimensional
    collection.'''
    temp=[]
    for i in range(len(m1[0])):
        temp.append([])           #makes a template for the new matrix
    for i in range(len(m1)):    #i is the current column  
        if len(m1[i])==len(m1[0]):
            for j in range(len(m1[i])):   #j is the current row
                temp[j].append(m1[i][j])
        else:
            raise ValueError('Invalid matrix, inconsistent column sizes.')
    return matrix(temp)


def axpy(a,x,y):
    '''axpy function takes a scalar a, and vectors x and y as arguments.
    returns a*x + y.'''
    return x*a + y


def dot(x,y):
    '''returns the dot product of vector x and vector y.'''
    if len(x)==len(y):
        v=0.0
        for i in range(len(x)):
            v+=x[i]*y[i]
        return v
    else:
        raise ValueError("The given vectors are of different sizes.")


def det(m):
    '''returns the determinant of the matrix.'''
    #matrix must be square:
    if(len(m) != len(m[0])):
        raise ValueError("Not a square matrix.")
    if(len(m)==2):
        return(m[0][0]*m[1][1] - m[0][1]*m[1][0])
    elif(len(m)>2):
        ans=m[0][0]-m[0][0]  #helps if the top row is vectors for a cross product
        for i in range(len(m[0])):
            l1=[]
            for j in range(1,len(m)):
                l2=[]
                for k in range(len(m[0])):
                    if(k!=i):
                        l2.append(m[j][k])
                l1.append(l2)
            submat=matrix(l1)
            ans+=((-1)**i)*m[0][i]*det(submat)
        return ans
    else:
        raise ValueError("Invalid Matrix")


def crossProduct(*args):
    '''Takes n-1 vectors of size n.  Takes the determinant of a matrix
    whose first row contains the unit vectors and the following rows are
    the supplied vectors in *args.'''
    row0=[]
    for i in range(len(args[0])):
        row0.append(unitVector(i,len(args[0])))
    m=[]
    m.append(row0)
    for vec in args:
        m.append(vec)
    return det(m)


def proj(x,y):
    '''Projection of vector x onto vector y.  Gives the component of x
    that is parallel to vector y.'''
    return (dot(x,y)/y.getLength()**2)*y


def norm(x,n=2):
    '''Returns the norm of a vector x.  Defaults to norm 2 which is the
    Euclidian norm, but other norms can be specified with n.'''
    ans=0
    for e in x:
        ans+=abs(e)**n
    return ans**(1.0/n)


def rowVec(*args):
    '''Constructs a matrix with one row from the given args.'''
    return matrix((args,))


def colVec(*args):
    '''Constructs a matrix with one column from the given args.'''
    l1=[]
    for e in args:
        l1.append((e,))
    return matrix(l1)


def linearCombination(l1,l2):
    '''Expects a list of constants (l1) and a list of vectors (l2).
    Performs a linear combination based on the given constants and vectors.
    This function also expects that all of the vectors in the second list
    are of the same size.'''
    ans=zeroVector(len(l2[0]))
    for i in range(len(l1)):
        ans+=l1[i]*l2[i]
    return ans


def mvMult(m,v):
    '''Matrix-vector multiplication.  This multiplies the matrix m by the
    vector v.'''
    if len(v)!=len(m[0]):
        raise ValueError("Incompatible matrix vector multiplication. "
        "The matrix has the wrong number of columns.")
    l1=[]
    for row in m:
        l1.append(dot(vector(row),v))
    return vector(l1)


def mmMult(m1,m2):
    '''Matrix-matrix multiplication.  This multiplies the matrix m1 by
    the matrix m2.'''
    l1=[]
    for col in m2.generateCols():
        l1.append(mvMult(m1,col))
    return transpose(matrix(l1))   #l1 contains the columns, whereas these matrices are row-major


def permutationMatrix(vec):
    '''Returns a permutation matrix based on the given permutation vector.'''
    l1=[]
    for i in range(len(vec)):
        row=[]
        for j in range(len(vec)):
            if(j==vec[i]):
                row.append(1)
            else:
                row.append(0)
        l1.append(row)
    return matrix(l1)


def GaussJordan(a, b):
    '''Solves a system of linear equations based on the given matrix.
    Solves for X in the problem AX=B with matrices A and B given.  a and
    b should be matrices.  To make b a column vector use colVec, which
    makes a matrix with one column.'''
    for i in range(len(a)):
        permVec = []
        if(a[i][i] == 0):
            try:
                permVec = permute(i, i, a)
            except IndexError:
                print("No Solution")
        else:
            permVec = vector([j for j in range(len(a))])
        a, b = mmMult(permutationMatrix(permVec), a), mmMult(permutationMatrix(permVec), b)
        transform = eliminate(i, a)
        a, b = mmMult(transform, a), mmMult(transform, b)
    # After that Gauss-Jordan elimination a is the identity matrix, so x=b.
    return b


def bestFit(m):
    '''Matrix m should contain 2 columns.  It should contain the ordered
    pairs of the points to which a line is to be fit.  Returns the value
    of m and b in the slope intercept form y=mx+b to define the line of
    best fit.  m and b are returned in the form of a vector in this way:
    (b,m).'''
    cols=[l for l in m.generateCols()]
    colb=[1 for n in range(len(m))]
    colm=cols[0]
    A=transpose(matrix((colb,colm)))
    ans=AxApproxB(A,matrix([(e,) for e in cols[1]]))
    return vector([e for e in ans.rcGenerator()])


def AxApproxB(A,b):
    '''For cases in which b is not in the column-space of A.  Returns the
    the best value of x which will approximately solve Ax=b.  Input A and
    b should be matrices.  To make b a column vector, use colVec, which
    makes a matrix with one column.'''
    return GaussJordan(mmMult(transpose(A),A),mmMult(transpose(A),b))


def permute(row,col,mat):
    '''Helper for GaussJordan.  Looks for a vector with a non-zero value
    in the given column after the given row, and constructs a permutation
    vector to switch the given row with the row it found.  Raises an 
    IndexError if no row is found.'''
    c=row
    permuteVec=[]
    while(True):
        if(mat[c][col]==0):
            c+=1
        else:
            for i in range(len(mat)):
                if(i==row):
                    permuteVec.append(c)
                elif(i==c):
                    permuteVec.append(row)
                else:
                    permuteVec.append(i)
            break
    return vector(permuteVec)


def eliminate(row,mat):
    '''Helper for GaussJordan.'''
    res=[]
    for i in range(len(mat)):
        l1=[]
        for j in range(len(mat[0])):
            if(i==row):
                if(j==row):
                    l1.append(1.0/mat[i][j])
                else:
                    l1.append(0.0)
            elif(j==row):
                l1.append((-1.0*mat[i][j])/mat[j][j])
            elif(i==j):
                l1.append(1.0)
            else:
                l1.append(0.0)
        res.append(l1)
    return matrix(res)


# Additional functions

def linSpace(lb, ub, n=500):
    '''Creates an iterable in the defined range, n defaults to 500'''
    return [lb + x*(ub-lb)/(n-1) for x in range(n)]


def polyVal(p, x):
    '''Evaluates the polynomial given by the coefficients in p at x'''
    ans = 0.
    for i in range(len(p)):
        ans += p[i]*(x**i)
    return ans


def polyAdd(p1, p2):
    '''Adds coefficients from 2 polynomials to create a combined polynomial'''
    if len(p1) < len(p2):  # Ensure p1 is the longer polynomial
        p1, p2 = p2, p1
    ans = list(p1)
    for i in range(len(p2)):
        ans[i] += p2[i]
    return ans


def polyMult(p, c):
    '''Multiplies a polynomial p by a constant c'''
    return [c*term for term in p]


def polySub(p1, p2):
    '''Subtracts p2 from p1 to create a combined polynomial'''
    return polyAdd(p1, polyMult(p2, -1))


def polyDiv(p, c):
    '''Divides a polynomial p by a constant c'''
    return polyMult(p, 1.0/c)


def polyDeriv(p, n=1):
    '''Returns the coefficients of the n-th derivative of p'''
    if n < 0:
        raise ValueError('n cannot be less than zero')
    ans = list(p)
    for i in range(n):
        ans = [j*ans[j] for j in range(1, len(ans))]
    return ans


def newtonsMethod(p, x0=0, maxIter=30, e=1e-8):
    '''Uses Newton's method to find a zero of the polynomial p near x0, within
    an error of e. Returns x where |f(x)| < e.'''
    pDeriv = polyDeriv(p)
    i = 1
    while abs(polyVal(p, x0)) > e:
        if i > maxIter:
            raise ValueError('no zero found')
        x0 = x0 - polyVal(p, x0)/polyVal(pDeriv, x0)
        i += 1
    return x0


def polyFit(x, y, n=2):
    '''Fits a n-th order polynomial to the data y at x.'''
    if len(x) != len(y):
        raise ValueError('data x and y should be the same length')
    X = transpose(matrix([vector(x)**i for i in range(n+1)]))
    Y = transpose(matrix([y]))
    fitV = AxApproxB(X, Y)
    return [s for s in fitV.rcGenerator()]
