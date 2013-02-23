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
    a % (1 x 1 number) Magnitude of real part of quaternion.
    b % (1 x 1 number) Magnitude of i part of quaternion.
    c % (1 x 1 number) Magnitude of j part of quaternion.
    d % (1 x 1 number) Magnitdue of k part of quaternion.
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
                a = 1; b = 0; c = 0; d = 0;
            case 1 % Quaternion Vector, Rotation Matrix, or Euler Angles
                assert(isnumeric(arg1) && isreal(arg1),...
                    'quaternion:arg1',...
                    'Input arguments must be real numbers.')
                
                switch numel(arg1)
                    case 4 % Quaternion
                        arg1 = arg1(:)';
                        a = arg1(1); b = arg1(2); c = arg1(3); d = arg1(4);
                        
                    case 9 % Rotation Matrix
                        arg1 = reshape(arg1(:),3,3);
                        q = quaternion.rot2quat(arg1);
                        a = q.a; b = q.b; c = q.c; d = q.d; 
                        
                    case 3 % Euler Angles or Axis
                        if size(arg1,1) == 1 % Euler Angles
                            q = quaternion.euler2quat(arg1);
                        else % Axis
                            q = quaternion.axis2quat(arg1);
                        end
                        a = q.a; b = q.b; c = q.c; d = q.d;
                        
                    otherwise
                        error('quaternion:arg1',...
                            'Invalid representation of a rotation.')
                end
                    
            case 2
                q = quaternion.axis2quat(arg1,arg2);
                a = q.a; b = q.b; c = q.c; d = q.d;
        end
        
        % Assign properties
        quaternionObj.a = a;
        quaternionObj.b = b;
        quaternionObj.c = c;
        quaternionObj.d = d;
        
    end
end
%-------------------------------------------------------------------------------

%% Property Methods ------------------------------------------------------------
% methods
%     function quaternionObj = set.prop1(quaternionObj,prop1)
%         % Overloaded assignment operator function for the "prop1" property.
%         %
%         % SYNTAX:
%         %   quaternionObj.prop1 = prop1
%         %
%         % INPUT:
%         %   prop1 - (1 x 1 real number)
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
%         assert(isnumeric(prop1) && isreal(prop1) && isequal(size(prop1),[1,1]),...
%             'quaternion:set:prop1',...
%             'Property "prop1" must be set to a 1 x 1 real number.')
% 
%         quaternionObj.prop1 = prop1;
%     end
%     
%     function prop1 = get.prop1(quaternionObj)
%         % Overloaded query operator function for the "prop1" property.
%         %
%         % SYNTAX:
%         %	  prop1 = quaternionObj.prop1
%         %
%         % OUTPUT:
%         %   prop1 - (1 x 1 real number)
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
% 
%         prop1 = quaternionObj.prop1;
%     end
% end
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
                
            case 'longG'
                space = '  ';
                flag = '%.15g';
                
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
                        fprintf([space flag],x(r,c).a);
                        if x(r,c).b == 0; x(r,c).b = 0; end
                        if x(r,c).b >= 0
                            fprintf([' + ' flag 'i'],x(r,c).b);
                        else
                            fprintf([' - ' flag 'i'],abs(x(r,c).b));
                        end
                        if x(r,c).c == 0; x(r,c).c = 0; end
                        if x(r,c).c >= 0
                            fprintf([' + ' flag 'j'],x(r,c).c);
                        else
                            fprintf([' - ' flag 'j'],abs(x(r,c).c));
                        end
                        if x(r,c).d == 0; x(r,c).d = 0; end
                        if x(r,c).d >= 0
                            fprintf([' + ' flag 'k'],x(r,c).d);
                        else
                            fprintf([' - ' flag 'k'],abs(x(r,c).d));
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
            scaler(i) = x(i).a;
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
            vector(ind2sub(d,i)) = x(i).b;
            vector(ind2sub(d,i+n)) = x(i).c;
            vector(ind2sub(d,i+2*n)) = x(i).d;
        end
    end
    
    function q = quat(x)
        % The "quat" method outputs the components of the quaternion "x".
        %
        % SYNTAX:
        %   quat(x)
        %
        % INPUTS:
        %   x - ( M x N x ... quaternion)
        %       An instance of the "quaternion" class.
        %
        % OUTPUTS:
        %   q - (M x N x ... x 4 real number)
        %       A matrix of the components of the quaternion "x" that is
        %       the same size as "x" plus one more dimension of size 4 that
        %       contains the each component a, b, c, d. To recover a the
        %       components of a specific element (i,j) of "x" use the
        %       following: >> squeeze(vector(i,j,:))'
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
        q = zeros([d 4]);
        for i = 1:n
            q(ind2sub(d,i)) = x(i).a;
            q(ind2sub(d,i+n)) = x(i).b;
            q(ind2sub(d,i+2*n)) = x(i).c;
            q(ind2sub(d,i+3*n)) = x(i).d;
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
        
        a1 = a.a; b1 = a.b; c1 = a.c; d1 = a.d;
        a2 = b.a; b2 = b.b; c2 = b.c; d2 = b.d;
        
        a.a = a1 + a2;
        a.b = b1 + b2;
        a.c = c1 + c2;
        a.d = d1 + d2;
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
        
        a1 = a.a; b1 = a.b; c1 = a.c; d1 = a.d;
        a2 = b.a; b2 = b.b; c2 = b.c; d2 = b.d;
        
        a.a = a1 - a2;
        a.b = b1 - b2;
        a.c = c1 - c2;
        a.d = d1 - d2;
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
            a1 = a.a; b1 = a.b; c1 = a.c; d1 = a.d;
        end
            
        if isa(b,'quaternion')
            a2 = b.a; b2 = b.b; c2 = b.c; d2 = b.d;
        end
            
        if isa(a,'quaternion') && isa(b,'quaternion')
            a.a = a1*a2 - b1*b2 - c1*c2 - d1*d2;
            a.b = a1*b2 + b1*a2 + c1*d2 - d1*c2;
            a.c = a1*c2 - b1*d2 + c1*a2 + d1*b2;
            a.d = a1*d2 + b1*c2 - c1*b2 + d1*a2;
        elseif isa(a,'quaternion')
            if numel(b) == 1
                a.a = a1*b;
                a.b = b1*b;
                a.c = c1*b;
                a.d = d1*b;
            else
                a2 = 0; b2 = b(1); c2 = b(2); d2 = b(3);
                a3 = a1*a2 - b1*b2 - c1*c2 - d1*d2;
                b3 = a1*b2 + b1*a2 + c1*d2 - d1*c2;
                c3 = a1*c2 - b1*d2 + c1*a2 + d1*b2;
                d3 = a1*d2 + b1*c2 - c1*b2 + d1*a2;
                
                a4 = a.a; b4 = -a.b; c4 = -a.c; d4 = -a.d;
                a = nan(3,1);
                a(1) = a3*b4 + b3*a4 + c3*d4 - d3*c4;
                a(2) = a3*c4 - b3*d4 + c3*a4 + d3*b4;
                a(3) = a3*d4 + b3*c4 - c3*b4 + d3*a4;
            end
        else
            b.a = a2*a;
            b.b = b2*a;
            b.c = c2*a;
            b.d = d2*a;
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
               
        a.a = a.a/b;
        a.b = a.b/b;
        a.c = a.c/b;
        a.d = a.d/b;
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
            q(i).b = -q(i).b;
            q(i).c = -q(i).c;
            q(i).d = -q(i).d;
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
        
        a1 = a.a; b1 = a.b; c1 = a.c; d1 = a.d;
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
        
        TF = (a.a == b.a & a.b == b.b & a.c == b.c & a.d == b.d);
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
        
        TF = (a.a ~= b.a | a.b ~= b.b | a.c ~= b.c | a.d ~= b.d);
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
        
        R = quaternion.quat2rot(a.a,a.b,a.c,a.d);
    end
    
    function R = euler(a)
        % The "euler" method outputs the corresponding Euler angles
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
            'quaternion:euler:a',...
            'Input argument "a" must be a 1 x 1 "quaternion" object.')
        
        R = quaternion.quat2euler(a.a,a.b,a.c,a.d);
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
        
        [e,theta] = quaternion.quat2axis(a.a,a.b,a.c,a.d);
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
            logic(i) = any(isnan([x(i).a x(i).b x(i).c x(i).d]));
        end
    end
end

methods (Static = true, Access = public)
    function q = rot2quat(rot)
        % The "rot2quat" method converts a rotation matrix to quaterion
        % components.
        %
        % SYNTAX:
        %   q = quaternion.rot2quat(rot)
        %
        % INPUTS:
        %   rot - (3 x 3 number)
        %       A standard rotation matrix that is in SO(3).
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
        assert(isnumeric(rot) && isreal(rot) && isequal(size(rot),[3,3]),...
            'quaternion:rot2quat:rot',...
            'Input argument "rot" must be a 3 x 3 matrix of real numbers in SO(3).')
        
        if norm(rot'*rot - eye(3)) > .01
            warning('quat2rot:rot',...
                'Input argument "rot" is not very close to SO(3). Results may be incorrect!!!')
        end
        
        % This method didn't work for all cases, e.g [-1 0 0;0 0 1;0 1 0]'
        % t = trace(rot);
        % r = sqrt(1+t);
        % s = 0.5/r;
        % a = 0.5*r;
        % b = (rot(3,2)-rot(2,3))*s;
        % c = (rot(1,3)-rot(3,1))*s;
        % d = (rot(2,1)-rot(1,2))*s;
        % 
        % q = [a b c d];

        % This method first convert the rotation matrix into axis-angle
        % representation and the converts that to a quaternion
        % http://en.wikipedia.org/wiki/Rotation_matrix#Conversion_from_and_to_axis-angle
        
        [V,D] = eigs(rot);
        [~,I] = max(real(diag(D)));
        u = V(:,I); % axis unit vector
        v = null(u'); v = v(:,1); % find a vector perpendicular to u.
        w = cross(u,v); % find another vector perpendicular to both with known right-hand orientation
        if (rot*v)'*w ~= 0
            theta = sign((rot*v)'*w)*acos((rot*v)'*v);
        else
            theta = acos((rot*v)'*v);
        end
        
        % t = trace(rot); % This method is ambiguous to the sign of the angle
        % theta = acos((t - 1)/2);
        
        if all(u < 0)
            u = -1*u;
            theta = wrapToPi(theta - 2*pi);
        end
        
        a = cos(theta/2);
        b = u(1)*sin(theta/2);
        c = u(2)*sin(theta/2);
        d = u(3)*sin(theta/2);
        
        q = quaternion([a b c d]);
        
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
        theta = 2*acos(a);
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
