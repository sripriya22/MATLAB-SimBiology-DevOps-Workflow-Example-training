classdef tgenerateSimFun < matlab.unittest.TestCase

    properties (Access=private)
        MATfilefullpath
        LoadedData
    end

    properties (ClassSetupParameter)
        MATfilename = {"test_generateSimFun.mat", string.empty}
    end

    properties (TestParameter)
        fieldName = {"simFun","doseTable","dependenciesSimFun"}
    end

    methods (Test)

        function testMATfileCreation(testCase)
            % Verify that the MAT file is created
            testCase.verifyTrue(isfile(testCase.MATfilefullpath), 'MAT file was not created.');
        end

        function testSimFunctionCreation(testCase, fieldName)
            % Verify that the MAT file contains required fields
            testCase.verifyTrue(isfield(testCase.LoadedData, fieldName), fieldName + " was not saved in " + testCase.MATfilefullpath);
        end

        function testSimFunctionAcceleration(testCase)
            % Verify that the SimFunction is accelerated
            testCase.verifyTrue(testCase.LoadedData.simFun.isAccelerated, "simFun was not accelerated.");
        end

    end

    methods (TestClassSetup)

        function classSetup(testCase, MATfilename)
            % Set up shared state for all tests.

            % Test if the simulation function is created successfully
            if isempty(MATfilename)
                testCase.MATfilefullpath = generateSimFun();
            else
                testCase.MATfilefullpath = generateSimFun(MATfilename);

                % delete file with testCase.addTeardown
                testCase.addTeardown(@delete,testCase.MATfilefullpath);
            end
            testCase.LoadedData = load(testCase.MATfilefullpath);

        end

    end
end