classdef quaternion
% The "quaternion" class used to represent quaternions.
%
% NOTES:
%   To get more information on this class type "doc quaternion" into the
%   command window.
%
%   The following websites are useful to learn more about quaternions:
%       http://en.wikipedia.org/wiki/Quaternion
%       http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
%       http://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions
%
% NECESSARY FILES AND/OR PACKAGES: TODO: Add necessary files
%   +somePackage, someFile.m
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 17-NOV-2012
%-------------------------------------------------------------------------------

%% Properties ------------------------------------------------------------------
properties (GetAccess = public, SetAccess = private, Hidden = true)
    r % (1 x 1 number) Magnitude of real part of quaternion.
    i % (1 x 1 number) Magnitude of i part of quaternion.
    j % (1 x 1 number) Magnitude of j part of quaternion.
    k % (1 x 1 number) Magnitdue of k part of quaternion.
end

properties (Dependent = true)
    quat
end

%% Constructor -----------------------------------------------------------------
methods
    function quaternionObj = quaternion(arg1,arg2)
        % Constructor function for the "quaternion" class.
        %
        % SYNTAX:
        %   quaternionObj = quaternion(quat)
        %   quaternionObj = quaternion(rot)
        %   quaternionObj = quaternion(euler)
        %   quaternionObj = quaternion(axis,angle)
        %
        % INPUTS:
        %   quat - (1 x 4 number)
        %       The new quaternion will be created with quaternion
        %       component representation.
        %
        %   rot - (3 x 3 number)
        %       The new quaternion will be created with a rotation matrix
        %       representation. Must be an element of SO(3).
        %
        %   euler - (1 x 3 number) 
        %       The new quaternion will be created with a Euler angles
        %       representation.
        %
        %   axis,angle - (3 x 1 number),(1 x 1 number)
        %       The new quaternion will be created with a Euler axis/angle
        %       representation. The angle is in radians and the the axis is
        %       unit vector. If only an axis is provided the angle equals
        %       the norm of the axis.
        %
        % OUTPUTS:
        %   quaternionObj - (1 x 1 quaternion object) 
        %       A new instance of the "quaternion" class.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        % Check number of arguments
        narginchk(0,2)
        
        switch nargin
            case 0 % Default
                r = 1; i = 0; j = 0; k = 0; %#ok<*PROP>
            case 1 % Quaternion Vector, Rotation Matrix, or Euler Angles
                assert(isnumeric(arg1) && isreal(arg1),...
                    'quaternion:arg1',...
                    'Input arguments must be real numbers.')
                
                switch numel(arg1)
                    case 4 % Quaternion
                        arg1 = arg1(:)';
                        r = arg1(1); i = arg1(2); j = arg1(3); k = arg1(4);
                        
                    case 9 % Rotation Matrix
                        arg1 = reshape(arg1(:),3,3);
                        q = quaternion.rot2quat(arg1);
                        r = q.r; i = q.i; j = q.j; d = q.k; 
                        
                    case 3 % Euler Angles or Axis
                        if size(arg1,1) == 1 % Euler Angles
                            q = quaternion.euler2quat(arg1);
                        else % Axis
                            q = quaternion.axis2quat(arg1);
                        end
                        r = q.r; i = q.i; j = q.k; k = q.k;
                        
                    otherwise
                        error('quaternion:arg1',...
                            'Invalid representation of a rotation.')
                end
                    
            case 2
                q = quaternion.axis2quat(arg1,arg2);
                r = q.r; i = q.i; j = q.j; k = q.k;
        end
        
        % Assign properties
        quaternionObj.r = r;
        quaternionObj.i = i;
        quaternionObj.j = j;
        quaternionObj.k = k;
        
    end
end
%-------------------------------------------------------------------------------

%% Property Methods ------------------------------------------------------------
methods
    function quaternionObj = set.quat(quaternionObj,quat)
        % Overloaded assignment operator function for the "prop1" property.
        %
        % SYNTAX:
        %   quaternionObj.prop1 = prop1
        %
        % INPUT:
        %   prop1 - (1 x 1 real number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isnumeric(quat) && isreal(quat) && numel(quat) == 4,...
            'quaternion:set:quat',...
            'Property "quat" must be set to a 4 x 1 real number.')

        quaternionObj.r = quat(1);
        quaternionObj.i = quat(2);
        quaternionObj.j = quat(3);
        quaternionObj.k = quat(4);
    end
    
    function quat = get.quat(quaternionObj)
        % Overloaded query operator function for the "quat" property.
        %
        % SYNTAX:
        %	  q = quaternionObj.quat
        %
        % OUTPUT:
        %   quat - (1 x 4 real number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        d = size(quaternionObj);
        if d(2) == 1
            d = d(1);
        end
        n = numel(quaternionObj);
        quat = zeros([d 4]);
        for cnt = 1:n
            quat(ind2sub(d,cnt)) = quaternionObj(cnt).r;
            quat(ind2sub(d,cnt+n)) = quaternionObj(cnt).i;
            quat(ind2sub(d,cnt+2*n)) = quaternionObj(cnt).j;
            quat(ind2sub(d,cnt+3*n)) = quaternionObj(cnt).k;
        end
    end
end
%-------------------------------------------------------------------------------

%% General Methods -------------------------------------------------------------
methods (Access = public)
    function disp(x)
        % The "disp" method overloads Matlab's built in "disp" function for
        % quaternions.
        %
        % SYNTAX:
        %   disp(x)
        %
        % INPUTS:
        %   x - (quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS: 
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        windowSize = get(0,'CommandWindowSize');
        charPerLine = windowSize(1);
        
        switch get(0,'Format')
            case 'short'
                space = '   ';
                flag = '%.4f';
                charPerCol = 39;
                
            case 'long'
                space = '  ';
                flag = '%.15f';
                
            case 'shortE'
                space = '   ';
                flag = '%.4e';
                
            case 'longE'
                space = '      ';
                flag = '%.15e';
                
            case 'shortG'
                space = '   ';
                flag = '%.4g';
                charPerCol = 39;
                
            case 'longG'
                space = '  ';
                flag = '%.15g';
                charPerCol = 39;
                
            otherwise
                error('quaternion:disp:format',...
                    'Format type "%s" has not been implemented yet for the quaternion class.',get(0,'Format'));
        end
        
        colPerLine = floor(charPerLine/charPerCol);
        
        dim = length(size(x));
        if dim <= 2
            rowMax = size(x,1);
            colMax = size(x,2);
            
            blockMax = ceil(colMax/colPerLine);
            
            colEnd = 0;
            for b = 1:blockMax
                colStart = colEnd + 1;
                colEnd = min(colStart + colPerLine - 1,colMax);
                if blockMax ~= 1
                    if colStart ~= colEnd
                        fprintf('  Columns %d through %d\n\n',colStart,colEnd);
                    else
                        fprintf('  Column %d\n\n',colStart);
                    end
                end
                
                for r = 1:rowMax
                    for c = colStart:colEnd
                        fprintf([space flag],x(r,c).r);
                        if x(r,c).i == 0; x(r,c).i = 0; end
                        if x(r,c).i >= 0
                            fprintf([' + ' flag 'i'],x(r,c).i);
                        else
                            fprintf([' - ' flag 'i'],abs(x(r,c).i));
                        end
                        if x(r,c).j == 0; x(r,c).j = 0; end
                        if x(r,c).j >= 0
                            fprintf([' + ' flag 'j'],x(r,c).j);
                        else
                            fprintf([' - ' flag 'j'],abs(x(r,c).j));
                        end
                        if x(r,c).k == 0; x(r,c).k = 0; end
                        if x(r,c).k >= 0
                            fprintf([' + ' flag 'k'],x(r,c).k);
                        else
                            fprintf([' - ' flag 'k'],abs(x(r,c).k));
                        end
                    end
                    fprintf('\n');
                end
                fprintf('\n');
            end
        else
            error('quaternion:disp:dim',...
                'Functionality to display quaternions with dimension greater than two has not been created yet.')
        end
    end
    
    function scaler = real(x)
        % The "real" method overloads Matlab's built in "real" function for
        % quaternions.
        %
        % SYNTAX:
        %   real(x)
        %
        % INPUTS:
        %   x - ( M x N x ... quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   scaler - (M x N x ... real number)
        %       A maxtrix of the real parts of the quaternion "x" that is
        %       the same size as "x".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        d = size(x);
        n = numel(x);
        scaler = zeros(d);
        for i = 1:n
            scaler(i) = x(i).r;
        end
    end
    
    function vector = imag(x)
        % The "imag" method overloads Matlab's built in "imag" function for
        % quaternions.
        %
        % SYNTAX:
        %   imag(x)
        %
        % INPUTS:
        %   x - ( M x N x ... quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   vector - (M x N x ... x 3 real number)
        %       A matrix of the imaginary parts of the quaternion "x" that
        %       is the same size as "x" plus one more dimension of size 3
        %       that contains the each imaginary coeffienct to the i, j, k
        %       component. To recover a the imaginary components of a
        %       specific element (i,j) of "x" use the following: >>
        %       squeeze(vector(i,j,:))'
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        d = size(x);
        if d(2) == 1
            d = d(1);
        end
        n = numel(x);
        vector = zeros([d 3]);
        for i = 1:n
            vector(ind2sub(d,i)) = x(i).i;
            vector(ind2sub(d,i+n)) = x(i).j;
            vector(ind2sub(d,i+2*n)) = x(i).k;
        end
    end
    
    function a = plus(a,b)
        % The "plus" method overloads Matlab's built in "plus" (i.e. + )
        % function for quaternions.
        %
        % SYNTAX:
        %   c = a + b
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   c - (1 x 1 quaternion)
        %       An instance of the "quaternion" class that is the
        %       sum of "a" added to "b".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:plus:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        assert(isa(b,'quaternion') && numel(b) == 1,...
            'quaternion:plus:b',...
            'Input argument "b" must be a 1 x 1 "quaternion" object.')
        
        a1 = a.r; b1 = a.i; c1 = a.j; d1 = a.k;
        a2 = b.r; b2 = b.i; c2 = b.k; d2 = b.k;
        
        a.r = a1 + a2;
        a.i = b1 + b2;
        a.j = c1 + c2;
        a.k = d1 + d2;
    end
    
    function a = minus(a,b)
        % The "minus" method overloads Matlab's built in "minus" (i.e. - )
        % function for quaternions.
        %
        % SYNTAX:
        %   c = a - b
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   c - (1 x 1 quaternion)
        %       An instance of the "quaternion" class that is the
        %       difference between "a" and "b".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:minus:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        assert(isa(b,'quaternion') && numel(b) == 1,...
            'quaternion:minus:b',...
            'Input argument "b" must be a 1 x 1 "quaternion" object.')
        
        a1 = a.r; b1 = a.i; c1 = a.j; d1 = a.k;
        a2 = b.r; b2 = b.k; c2 = b.j; d2 = b.k;
        
        a.r = a1 - a2;
        a.i = b1 - b2;
        a.j = c1 - c2;
        a.k = d1 - d2;
    end
    
    function a = times(a,b)
        % The "times" method overloads Matlab's built in "times" (i.e. .* )
        % function for quaternions.
        %
        % SYNTAX:
        %   c = a .* b
        %
        % INPUTS:
        %   a - (1 x N scaler or quaternion or 3 x N vector)
        %       First argument in product equation.
        %
        %   b - (1 x N scaler or quaternion or 3 x N vector)
        %       Second argument in product equation.
        %
        % OUTPUTS:
        %   c - (1 x N quaternion or 3 x N vector)
        %       Product of equation.
        %
        % NOTES:
        %   This method works for:
        %       quaternion .* quaternion = quaternion -- elementwise Hamiltonian product
        %       scaler .* quaternion or quaternion .* scaler = quaternion -- elementwise scaler product
        %       quaternion * vector (3 x 1) = vector (3 x 1) -- elementwise rotational product 
        %
        %-----------------------------------------------------------------------
        
        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(isa(a,'quaternion') || (isnumeric(a) && isreal(a) && isvector(a)),...
            'quaternion:times:a',...
            'Input argument "a" must be a real scaler, vector or "quaternion" vector object.')
        [M,N] = size(a);
        
        assert((isa(b,'quaternion') && isequal(size(b),[M,N])) || (isnumeric(b) && isreal(b) && (isequal(size(b),[M,N]) || (M == 1 && isequal(size(b),[3,N])))),...
            'quaternion:times:b',...
            'Input argument "b" must be a %d x %d real matrix, 3 x %d matrix, or  %d x %d "quaternion" vector object.',M,N,N,M,N)
        
        if M == 1 && size(b,1) == 3
            c = nan(3,N);
            for i = 1:N
                c(:,i) = a(i) * b(:,i);
            end
            a = c;
        else
            for i = 1:numel(b)
                a(i) = a(i) * b(i);
            end
        end
    end
        
    function a = mtimes(a,b)
        % The "mtimes" method overloads Matlab's built in "mtimes" (i.e. *
        % ) function for quaternions.
        %
        % SYNTAX:
        %   c = a * b
        %
        % INPUTS:
        %   a - (1 x 1 scaler or quaternion)
        %       First argument in product equation.
        %
        %   b - (1 x 1 scaler or quaternion or 3 x 1 vector)
        %       Second argument in product equation.
        %
        % OUTPUTS:
        %   c - (1 x 1 quaternion or 3 x 1 vector)
        %       Product of equation.
        %
        % NOTES:
        %   This method works for:
        %       quaternion * quaternion = quaternion -- Hamiltonian product
        %       scaler * quaternion or quaternion * scaler = quaternion -- scaler product
        %       quaternion * vector (3 x 1) = vector (3 x 1) -- rotational product 
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert((isa(a,'quaternion') && numel(a) == 1) || (isnumeric(a) && isreal(a) && numel(a) == 1),...
            'quaternion:mtimes:a',...
            'Input argument "a" must be a real scaler or 1 x 1 "quaternion" object.')
        
        assert((isa(b,'quaternion') && numel(b) == 1) || (isnumeric(b) && isreal(b) && (numel(b) == 1 || isequal(size(b),[3,1]))),...
            'quaternion:mtimes:b',...
            'Input argument "b" must be a real scaler, 3 x 1 vector, or 1 x 1 "quaternion" object.')
        
        if isa(a,'quaternion') 
            r1 = a.r; i1 = a.i; j1 = a.j; k1 = a.k;
        end
            
        if isa(b,'quaternion')
            r2 = b.r; i2 = b.i; j2 = b.j; k2 = b.k;
        end
            
        if isa(a,'quaternion') && isa(b,'quaternion')
            a.r = r1*r2 - i1*i2 - j1*j2 - k1*k2;
            a.i = r1*i2 + i1*r2 + j1*k2 - k1*j2;
            a.j = r1*j2 - i1*k2 + j1*r2 + k1*i2;
            a.k = r1*k2 + i1*j2 - j1*i2 + k1*r2;
        elseif isa(a,'quaternion')
            if numel(b) == 1
                a.r = r1*b;
                a.i = i1*b;
                a.j = j1*b;
                a.k = k1*b;
            else
                r2 = 0; i2 = b(1); j2 = b(2); k2 = b(3);
                a3 = r1*r2 - i1*i2 - j1*j2 - k1*k2;
                b3 = r1*i2 + i1*r2 + j1*k2 - k1*j2;
                c3 = r1*j2 - i1*k2 + j1*r2 + k1*i2;
                d3 = r1*k2 + i1*j2 - j1*i2 + k1*r2;
                
                a4 = a.r; b4 = -a.i; c4 = -a.j; d4 = -a.k;
                a = nan(3,1);
                a(1) = a3*b4 + b3*a4 + c3*d4 - d3*c4;
                a(2) = a3*c4 - b3*d4 + c3*a4 + d3*b4;
                a(3) = a3*d4 + b3*c4 - c3*b4 + d3*a4;
            end
        else
            b.r = r2*a;
            b.i = i2*a;
            b.j = j2*a;
            b.k = k2*a;
            a = b;
        end  
    end
    
    function a = mrdivide(a,b)
        % The "mrdivide" method overloads Matlab's built in "mrdivide"
        % (i.e. / ) function for quaternions.
        %
        % SYNTAX:
        %   c = a / b
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        %   b - (1 x 1 scaler)
        %       Scaler divisor.
        %
        % OUTPUTS:
        %   c - (1 x 1 quaternion)
        %       An instance of the "quaternion" class that is the
        %       quotient of "a" divided by "b".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:mrdivide:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        assert(isnumeric(b) && isreal(b) && numel(b) == 1,...
            'quaternion:mrdivide:b',...
            'Input argument "b" must be a 1 x 1 real scaler value.')
               
        a.r = a.r/b;
        a.i = a.i/b;
        a.j = a.j/b;
        a.k = a.k/b;
    end
    
    function q = conj(q)
        % The "conj" method overloads Matlab's built in "conj" function for
        % quaternions.
        %
        % SYNTAX:
        %   b = conj(a)
        %
        % INPUTS:
        %   a - (M x N x ... quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   b - (M x N x ... quaternion)
        %       An instance of the "quaternion" class that is elementwise the
        %       conjucate of "a".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Elementwise conjucate
        for i = 1:numel(q)
            q(i).i = -q(i).i;
            q(i).j = -q(i).j;
            q(i).k = -q(i).k;
        end
    end
    
    function r = ctranspose(q)
        % The "conj" method overloads Matlab's built in "ctranspose" (i.e.
        % ' )function for quaternions.
        %
        % SYNTAX:
        %   b = a'
        %
        % INPUTS:
        %   a - (M x N quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   b - (M x N quaternion)
        %       An instance of the "quaternion" class that is the conjucate
        %       transpose of "a".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(size(q)) == 2,...
            'quaternion:norm:a',...
            'Input argument "a" must have dimension <= 2.')
        
        % Conjucate transpose
        [M,N] = size(q);
        r = reshape(q,N,M);
        for i = 1:M
            for j = 1:N
                r(j,i) = conj(q(i,j));
            end
        end
    end
    
    function value = norm(a)
        % The "norm" method overloads Matlab's built in "norm" function for
        % quaternions.
        %
        % SYNTAX:
        %   value = norm(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   value - (1 x 1 number)
        %       The norm of the quaternion "a".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:norm:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        a1 = a.r; b1 = a.i; c1 = a.j; d1 = a.k;
        value = norm([a1 b1 c1 d1]);
    end
    
    function a = unit(a)
        % The "unit" method outputs the corresponding unit quaternion to
        % the quaternion "a" or known as the versor.
        %
        % SYNTAX:
        %   b = quat(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class that is the
        %       unit quaternion to "a".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:unit:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        a = a/norm(a);
    end
    
    function b = inv(a)
        % The "inv" method overloads Matlab's built in "inv" function for
        % quaternions.
        %
        % SYNTAX:
        %   b = inv(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class that is the
        %       inverse quaternion to "a".
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:inv:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        b = conj(a)/norm(a)^2;
    end
    
    function TF = eq(a,b)
        % The "eq" method overloads Matlab's built in "eq" (i.e. == )
        % function for quaternions.
        %
        % SYNTAX:
        %   a == b
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   TF - (1 x 1 logical)
        %       True if all of the components of the quaternions "a" and "b"
        %       equal each other.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:eq:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        assert(numel(b) == 1,...
            'quaternion:eq:b',...
            'Input argument "b" must be a 1 x 1 "quaternion" object.')
        
        TF = (a.r == b.r & a.i == b.i & a.j == b.j & a.k == b.k);
    end
    
    function TF = ne(a,b)
        % The "ne" method overloads Matlab's built in "ne" (i.e. ~= )
        % function for quaternions.
        %
        % SYNTAX:
        %   a ~= b
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        %   b - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   TF - (1 x 1 logical)
        %       True if any of the components of the quaternions "a" and "b"
        %       do not equal each other.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:eq:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        assert(numel(b) == 1,...
            'quaternion:eq:b',...
            'Input argument "b" must be a 1 x 1 "quaternion" object.')
        
        TF = (a.r ~= b.r | a.i ~= b.i | a.j ~= b.j | a.k ~= b.k);
    end
    
    function R = rot(a)
        % The "rot" method outputs the corresponding rotation matrix
        % associated with the quaternion "a".
        %
        % SYNTAX:
        %   R = rot(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   R - (3 x 3 number)
        %       A standard rotation matrix that is in SO(3).
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:rot:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        R = quaternion.quat2rot(a.r,a.i,a.j,a.k);
    end
    
    function E = euler(a)
        % The "euler" method outputs the corresponding Euler angles
        % associated with the quaternion "a".
        %
        % SYNTAX:
        %   E = euler(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   E - (1 x 3 number) 
        %       Euler angles [phi; theta; psi] for the given quaterion.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:euler:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        E = quaternion.quat2euler(a.r,a.i,a.j,a.k);
    end
    
    function psi = yaw(a)
        % The "yaw" method outputs the corresponding yaw angle
        % associated with the quaternion "a".
        %
        % SYNTAX:
        %   E = yaw(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   psi - (1 x 1 number) 
        %       Yaw angle for the given quaterion.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:euler:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        E = quaternion.quat2euler(a.r,a.i,a.j,a.k);
        psi = E(3);
    end
    
    
    
    function [e,theta] = axis(a)
        % The "axis" method outputs the corresponding Euler axis/angle
        % representation of a rotation that is equal to the quaternion "a".
        %
        % SYNTAX:
        %   [e,theta] = axis(a)
        %
        % INPUTS:
        %   a - (1 x 1 quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS
        %   e - (3 x 1 number)
        %       Axis of rotation. Magnitude of axis equals angle of
        %       rotation.
        %
        %   theta - (1 x 1 number)
        %       Angle of rotation.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(numel(a) == 1,...
            'quaternion:axis:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        [e,theta] = quaternion.quat2axis(a.r,a.i,a.j,a.k);
        if e(3) < 0
            e = -e;
            theta = -theta;
        end
    end
    
    function logic = isnan(x)
        % The "isnan" method overloads Matlab's built in "isnan" function for
        % quaternions.
        %
        % SYNTAX:
        %   isnan(x)
        %
        % INPUTS:
        %   x - ( M x N x ... quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   logic - (M x N x ... logical)
        %       A maxtrix of logical the same size of "x", which are true
        %       if any part of the quaternion "x" is equal to a NaN.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        d = size(x);
        n = numel(x);
        logic = zeros(d);
        for i = 1:n
            logic(i) = any(isnan([x(i).r x(i).i x(i).j x(i).k]));
        end
    end
end

methods (Static = true, Access = public)
    function q = rot2quat(R)
        % The "rot2quat" method converts a rotation matrix to quaterion
        % components.
        %
        % SYNTAX:
        %   q = quaternion.rot2quat(rot)
        %
        % INPUTS:
        %   R - (3 x 3 number)
        %       A standard rotation matrix that is in SO(3).
        %
        % OUTPUTS:
        %   q = (1 x 4 numbers)
        %       Quaterion components: q(1) + q(2)*i + q(3)*j + q(4)*k.
        %
        % NOTES:
        %   See http://www.cg.info.hiroshima-cu.ac.jp/~miyazaki/knowledge/teche52.html
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(isnumeric(R) && isreal(R) && isequal(size(R),[3,3]),...
            'quaternion:rot2quat:R',...
            'Input argument "R" must be a 3 x 3 matrix of real numbers in SO(3).')
        
        if norm(R'*R - eye(3)) > .01
            warning('quat2rot:rot',...
                'Input argument "rot" is not very close to SO(3). Results may be incorrect!!!')
        end
        
        N = size(R,3);

        R11 = squeeze(R(1,1,:))';
        R12 = squeeze(R(1,2,:))';
        R13 = squeeze(R(1,3,:))';
        
        R21 = squeeze(R(2,1,:))';
        R22 = squeeze(R(2,2,:))';
        R23 = squeeze(R(2,3,:))';
        
        R31 = squeeze(R(3,1,:))';
        R32 = squeeze(R(3,2,:))';
        R33 = squeeze(R(3,3,:))';
        
        r = 1/4*( R11 + R22 + R33 + ones(1,N));
        i = 1/4*( R11 - R22 - R33 + ones(1,N));
        j = 1/4*(-R11 + R22 - R33 + ones(1,N));
        k = 1/4*(-R11 - R22 + R33 + ones(1,N));
        
        r(r<0) = 0;
        i(i<0) = 0;
        j(j<0) = 0;
        k(k<0) = 0;
        
        r = r.^(1/2);
        i = i.^(1/2);
        j = j.^(1/2);
        k = k.^(1/2);
        
        q = nan(4,N);
        
        ind1 = (r >= i & r >= j & r >= k);
        q(1,ind1) = r(ind1);
        q(2,ind1) = sign(R32(ind1) - R23(ind1)).*i(ind1);
        q(3,ind1) = sign(R13(ind1) - R31(ind1)).*j(ind1);
        q(4,ind1) = sign(R21(ind1) - R12(ind1)).*k(ind1);
        
        ind2 = (i >= r & i >= j & r >= k);
        q(1,ind2) = sign(R32(ind2) - R23(ind2)).*r(ind2);
        q(2,ind2) = i(ind2);
        q(3,ind2) = sign(R21(ind2) + R12(ind2)).*j(ind2);
        q(4,ind2) = sign(R13(ind2) + R31(ind2)).*k(ind2);
        
        ind3 = (j >= r & j >= i & j >= k);
        q(1,ind3) = sign(R13(ind3) - R31(ind3)).*r(ind3);
        q(2,ind3) = sign(R21(ind3) + R12(ind3)).*i(ind3);
        q(3,ind3) = j(ind3);
        q(4,ind3) = sign(R32(ind3) + R23(ind3)).*k(ind3);
        
        ind4 = (k >= r & k >= i & k >= j);
        q(1,ind4) = sign(R21(ind4) - R12(ind4)).*r(ind4);
        q(2,ind4) = sign(R31(ind4) + R13(ind4)).*i(ind4);
        q(3,ind4) = sign(R32(ind4) + R23(ind4)).*j(ind4);
        q(4,ind4) = k(ind4);
        
        q_norm = sqrt(sum(q.^2,1));
        
        q = q ./ repmat(q_norm,4,1);
        
        q = quaternion(q');
        
    end
    
    function R = quat2rot(a,b,c,d)
        % The "quat2rot" method converts a converts a quaterion to a
        % rotation matrix.
        %
        % SYNTAX:
        %   R = quaternion.quat2rot(q)
        %   R = quaternion.quat2rot(a,b,c,d)
        %
        % INPUTS:
        %   q - (1 x 4 number)
        %       Quaterion components in vector form.
        %
        %   [a,b,c,d] - (1 x 1 numbers)
        %       Quaterion components: a + b*i + c*j + d*k.
        %
        % OUTPUTS:
        %   rot - (3 x 3 number)
        %       A standard rotation matrix that is in SO(3).
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,4)
        
        % Check arguments for errors
        if nargin == 1
            q = a;
            assert(isnumeric(q) && isreal(q) && numel(q) == 4,...
                'quaternion:quat2rot:q',...
                'Input argument "q" must be a 1 x 1 real number.')
            a = q(1); b = q(2); c = q(3); d = q(4);
            
        elseif nargin == 4
            assert(isnumeric(a) && isreal(a) && numel(a) == 1,...
                'quaternion:quat2rot:a',...
                'Input argument "a" must be a 1 x 1 real number.')
            
            assert(isnumeric(b) && isreal(b) && numel(b) == 1,...
                'quaternion:quat2rot:b',...
                'Input argument "b" must be a 1 x 1 real number.')
            
            assert(isnumeric(c) && isreal(c) && numel(c) == 1,...
                'quaternion:quat2rot:c',...
                'Input argument "c" must be a 1 x 1 real number.')
            
            assert(isnumeric(d) && isreal(d) && numel(d) == 1,...
                'quaternion:quat2rot:d',...
                'Input argument "d" must be a 1 x 1 real number.')
        else
            error('quaternion:quat2rot:nargin',...
                'Incorrect number of input arugments.')
        end
        
        R = [a^2+b^2-c^2-d^2    2*b*c-2*a*d     2*b*d+2*a*c;...
             2*b*c+2*a*d        a^2-b^2+c^2-d^2 2*c*d-2*a*b;...
             2*b*d-2*a*c        2*c*d+2*a*b     a^2-b^2-c^2+d^2];
    end
    
    function q = euler2quat(euler)
        % The "euler2quat" method converts Euler angles to quaterion
        % components.
        %
        % SYNTAX:
        %   q = quaternion.euler2quat(euler)
        %
        % INPUTS:
        %   euler - (1 x 3 number) 
        %       Euler angles [phi theta psi].
        %
        % OUTPUTS:
        %   q = (1 x 4 numbers)
        %       Quaterion components: q(1) + q(2)*i + q(3)*j + q(4)*k.
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        
        % Check arguments for errors
        assert(isnumeric(euler) && isreal(euler) && numel(euler) == 3,...
            'quaternion:rot2quat:euler',...
            'Input argument "euler" must be a 3 x 1 vector of real numbers.')
        euler = euler(:)';
        
        phi = euler(1); theta = euler(2); psi = euler(3);
        
        a = cos(phi/2)*cos(theta/2)*cos(psi/2) + sin(phi/2)*sin(theta/2)*sin(psi/2);
        b = sin(phi/2)*cos(theta/2)*cos(psi/2) - cos(phi/2)*sin(theta/2)*sin(psi/2);
        c = cos(phi/2)*sin(theta/2)*cos(psi/2) + sin(phi/2)*cos(theta/2)*sin(psi/2);
        d = cos(phi/2)*cos(theta/2)*sin(psi/2) - sin(phi/2)*sin(theta/2)*cos(psi/2);
        
        q = quaternion([a b c d]);
    end
    
    function euler = quat2euler(a,b,c,d)
        % The "quat2euler" method converts a converts a quaterion to a
        % Euler angles.
        %
        % SYNTAX:
        %   euler = quaternion.quat2euler(q)
        %   euler = quaternion.quat2euler(a,b,c,d)
        %
        % INPUTS:
        %   q - (1 x 4 number)
        %       Quaterion components in vector form.
        %
        %   [a,b,c,d] - (1 x 1 numbers)
        %       Quaterion components: a + b*i + c*j + d*k.
        %
        % OUTPUTS:
        %   euler - (1 x 3 number) 
        %       Euler angles [phi; theta; psi] for the given quaterion.
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,4)
        
        % Check arguments for errors
        if nargin == 1
            q = a;
            assert(isnumeric(q) && isreal(q) && numel(q) == 4,...
                'quaternion:quat2euler:q',...
                'Input argument "q" must be a 1 x 1 real number.')
            a = q(1); b = q(2); c = q(3); d = q(4);
            
        elseif nargin == 4
            assert(isnumeric(a) && isreal(a) && numel(a) == 1,...
                'quaternion:quat2euler:a',...
                'Input argument "a" must be a 1 x 1 real number.')
            
            assert(isnumeric(b) && isreal(b) && numel(b) == 1,...
                'quaternion:quat2euler:b',...
                'Input argument "b" must be a 1 x 1 real number.')
            
            assert(isnumeric(c) && isreal(c) && numel(c) == 1,...
                'quaternion:quat2euler:c',...
                'Input argument "c" must be a 1 x 1 real number.')
            
            assert(isnumeric(d) && isreal(d) && numel(d) == 1,...
                'quaternion:quat2euler:d',...
                'Input argument "d" must be a 1 x 1 real number.')
        else
            error('quaternion:quat2euler:nargin',...
                'Incorrect number of input arugments.')
        end
        
        phi = atan2(2*(a*b+c*d),1-2*(b^2+c^2));
        theta = asin(2*(a*c-d*b));
        psi = atan2(2*(a*d+b*c),1-2*(c^2+d^2));
        
        euler = [phi theta psi];
    end
    
    function q = axis2quat(e,theta)
        % The "axis2quat" method converts Euler axis/angle rotation
        % representation to quaterion components.
        %
        % SYNTAX:
        %   q = quaternion.axis2quat(e)
        %   q = quaternion.axis2quat(e,theta)
        %
        % INPUTS:
        %   e - (3 x 1 number)
        %       Axis of rotation.
        %
        %   theta - (1 x 1 number) [norm(e)]
        %       Angle in radians. If not given it is set to the norm of
        %       axis "e".
        %
        % OUTPUTS:
        %   q = (1 x 4 numbers)
        %       Quaterion components: q(1) + q(2)*i + q(3)*j + q(4)*k.
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,2)
        
        % Check arguments for errors
        assert(isnumeric(e) && isreal(e) && numel(e) == 3,...
            'quaternion:axis2quat:e',...
            'Input argument "e" must be a 3 x 1 vector of real numbers.')
        e = e(:);
        
        if nargin < 2; theta = norm(e); end
        
        assert(isnumeric(theta) && isreal(theta) && numel(theta) == 1,...
            'quaternion:axis2quat:theta',...
            'Input argument "theta" must be a 1 x 1 real number.')
        
        e = e / norm(e);
        
        a = cos(theta/2);
        b = e(1)*sin(theta/2);
        c = e(2)*sin(theta/2);
        d = e(3)*sin(theta/2);
        
        q = quaternion([a b c d]);
    end
    
    function [e,theta] = quat2axis(a,b,c,d)
        % The "quat2euler" method converts a converts a quaterion to a
        % Euler axis/angle rotation representation.
        %
        % SYNTAX:
        %   e = quaternion.quat2axis(q)
        %   e = quaternion.quat2axis(a,b,c,d)
        %
        % INPUTS:
        %   q - (1 x 4 number)
        %       Quaterion components in vector form.
        %
        %   [a,b,c,d] - (1 x 1 numbers)
        %       Quaterion components: a + b*i + c*j + d*k.
        %
        % OUTPUTS:
        %   e - (3 x 1 number)
        %       Axis of rotation. Magnitude equals angle of rotation.
        %
        %   theta - (1 x 1 number)
        %       Angle of rotation.
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,4)
        
        % Check arguments for errors
        if nargin == 1
            q = a;
            assert(isnumeric(q) && isreal(q) && numel(q) == 4,...
                'quaternion:quat2axis:q',...
                'Input argument "q" must be a 1 x 1 real number.')
            a = q(1); b = q(2); c = q(3); d = q(4);
            
        elseif nargin == 4
            assert(isnumeric(a) && isreal(a) && numel(a) == 1,...
                'quaternion:quat2axis:a',...
                'Input argument "a" must be a 1 x 1 real number.')
            
            assert(isnumeric(b) && isreal(b) && numel(b) == 1,...
                'quaternion:quat2axis:b',...
                'Input argument "b" must be a 1 x 1 real number.')
            
            assert(isnumeric(c) && isreal(c) && numel(c) == 1,...
                'quaternion:quat2axis:c',...
                'Input argument "c" must be a 1 x 1 real number.')
            
            assert(isnumeric(d) && isreal(d) && numel(d) == 1,...
                'quaternion:quat2axis:d',...
                'Input argument "d" must be a 1 x 1 real number.')
        else
            error('quaternion:quat2axis:nargin',...
                'Incorrect number of input arugments.')
        end
        
        e = [b;c;d]/norm([b;c;d]);
        theta = 2*real(acos(a));
        if theta > pi
            theta = theta - 2*pi;
        elseif theta < -pi
            theta = theta + 2*pi;
        end
        e = theta*e;
        
    end
    
end
%-------------------------------------------------------------------------------

%% Converting Methods ----------------------------------------------------------
% methods
%     function anOtherObject = otherObject
%         % Function to convert quaternion object to a otherObject object.
%         %
%         % SYNTAX:
%         %	  otherObject(quaternionObj)
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
%         
% 
%     end
% 
% end
%-------------------------------------------------------------------------------

%% Methods in separte files ----------------------------------------------------
% methods (Access = public)
%     quaternionObj = someMethod(quaternionObj,arg1)
% end
%-------------------------------------------------------------------------------
    
end
