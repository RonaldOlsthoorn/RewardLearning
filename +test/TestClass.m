classdef TestClass
    
    properties( Constant )
        
        c=0;
    end
    
    methods
        
        function obj = TestClass()
            
        end
        
        function getC(obj)
            import test.TestClass;
            disp(TestClass.c);
        end
    end
    
end