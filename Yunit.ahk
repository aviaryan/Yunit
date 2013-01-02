#NoEnv

class Yunit
{
    static Modules := [Yunit.StdOut]
    
    class Tester extends Yunit
    {
        __New(Modules)
        {
            this.Modules := Modules
        }
    }
    
    Use(Modules*)
    {
        return new this.Tester(Modules)
    }
    
    Test(classes*) ; static method
    {
        instance := new this()
        instance.results := {}
        instance.classes := classes
        instance.Modules := []
        for k,module in instance.base.Modules
            instance.Modules[k] := new module(instance)
        while A_Index <= classes.MaxIndex()
        {
            cls := classes[A_Index]
            instance.current := A_Index
            instance.results[cls.__class] := obj := {}
            instance.TestClass(obj, cls)
        }
    }
    
    Update(Category, Test, Result)
    {
        for k,module in this.Modules
            module.Update(Category, Test, Result)
    }
    
    TestClass(results, cls)
    {
        environment := new cls() ; calls __New
        for k,v in cls
        {
            if IsObject(v) && IsFunc(v) ;test
            {
                if k in Begin,End
                    continue
                if ObjHasKey(cls,"Begin") 
                && IsFunc(cls.Begin)
                    environment.Begin()
                result := 0
                try
                {
                    v.(environment)
                    if ObjHasKey(environment, "ExpectedException")
                        throw Exception("ExpectedException")
                }
                catch error
                {
                    if !ObjHasKey(environment, "ExpectedException")
                    || !this.CompareValues(environment.ExpectedException, error)
                        result := error
                }
                results[k] := result
                ObjRemove(environment, "ExpectedException")
                this.Update(cls.__class, k, results[k])
                if ObjHasKey(cls,"End")
                && IsFunc(cls.End)
                    environment.End()
            }
            else if IsObject(v)
            && ObjHasKey(v, "__class") ;category
                this.classes.Insert(++this.current, v)
        }
    }
    
    Assert(Value, Message = "FAIL")
    {
        if (!Value)
            throw Exception(Message, -1)
    }
    
    CompareValues(v1, v2)
    {   ; Support for simple exceptions. May need to be extended in the future.
        if !IsObject(v1) || !IsObject(v2)
            return v1 = v2   ; obey StringCaseSense
        if !ObjHasKey(v1, "Message") || !ObjHasKey(v2, "Message")
            return False
        return v1.Message = v2.Message
    }
}

/* Module example.

; file should be Lib\Yunit\MyModule.ahk
; included like this: 
#Include <Yunit\MyModule>

; usage:
Yunit.Use(YunitMyModule).Test(class1, class2, ...)

class YunitMyModule
{ 
    __New(instance)
    {
        ; setup code here
        ; instance is the instance of Yunit
        ; instance.results is a persistent object that 
        ;   is updated just before Update() is called
    }
    
    Update(category, test, result)
    {
        ; update code here
        ; called every time a test is finished
    }
}

*/