%% Class to handle pointwise multiplication

classdef Diagonal < handle
    properties
        D
    end
    
    methods
        function C=Diagonal(D)
            C.D=D;
        end
        
        function C=plus(A,B)
            switch [class(A),class(B)]
                case ['Diagonal','Diagonal']
                    C=Diagonal(A.D+B.D);
                case ['Diagonal','double']
                    C=A+B*Diagonal.eye(size(A.D));
                case ['double','Diagonal']
                    C=B+A*Diagonal.eye(size(B.D));
                otherwise
                    throw(MException('ResultChk:BadInput','Can not add classes %s and %s',class(A),class(B)))
                    
            end
        end
        
        
        function C=mtimes(A,B)
            switch class(A)
                case 'double'
                    C=Diagonal(A*B.D);
                case 'Diagonal'
                    switch class(B)
                        case 'Diagonal'
                            C=Diagonal(A.D.*B.D);
                        case 'double'
                            C=A.D.*B;
                        otherwise
                            throw(MException('ResultChk:BadInput','Can not multiply classes %s and %s',class(A),class(B)))
   
                    end
                otherwise
                    throw(MException('ResultChk:BadInput','Can not multiply classes %s and %s',class(A),class(B)))
                    
                    
            end
        end
        
        function C=ctranspose(A)
            C=Diagonal(conj(A.D));
        end
        
        function C=mldivide(A,B)
            C=B./A.D;
        end
    end
    
    
    methods(Static)
        
       function C=eye(sz)
            C=Diagonal(ones(sz));
       end
       
       function C=Gradient(sz,dir)
           [X,Y]=meshgrid(linspace(-1,1,sz(2)),linspace(-1,1,sz(1)));
           C=Diagonal(X*dir(1)+Y*dir(2));
       end
    end
    
end