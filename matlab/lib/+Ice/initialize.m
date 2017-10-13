function [communicator, args] = initialize(varargin)
    % initialize  Creates a communicator.
    %
    % Examples:
    %   communicator = Ice.initialize();
    %   [communicator, remArgs] = Ice.initialize(args);
    %   communicator = Ice.initialize(initData);
    %   [communicator, remArgs] = Ice.initialize(args, initData);
    %
    % Parameters:
    %   args (cell array of char) - An optional argument vector. Any Ice-related
    %     options in this vector are used to initialize the communicator.
    %   initData (Ice.InitializationData) - Optional additional initialization data.
    %
    % Returns:
    %   communicator (Ice.Communicator) - The new communicator.
    %   args (cell array of char) - Contains the remaining command-line arguments
    %     that were not used to set properties.

    % Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.

    if length(varargin) > 2
        throw(MException('Ice:ArgumentException', 'too many arguments to Ice.initialize'));
    end

    args = {};
    initData = [];

    for i = 1:length(varargin)
        if isa(varargin{i}, 'cell') && isempty(args)
            args = varargin{i};
        elseif isa(varargin{i}, 'Ice.InitializationData') && isempty(initData)
            initData = varargin{i};
        else
            throw(MException('Ice:ArgumentException', 'unexpected argument to Ice.initialize'));
        end
    end

    if isempty(initData)
        initData = Ice.InitializationData();
    end

    if isempty(initData.valueFactoryManager)
        %
        % Supply a default implementation of ValueFactoryManager.
        %
        initData.valueFactoryManager = Ice.ValueFactoryManagerI();
    elseif ~isa(initData.valueFactoryManager, 'Ice.ValueFactoryManager')
        throw(MException('Ice:ArgumentException', 'invalid value for valueFactoryManager member'));
    end

    %
    % Implementation notes:
    %
    % We need to extract and pass the libpointer object for properties to the C function. Passing the wrapper
    % (Ice.Properties) object won't work because the C code has no way to obtain the inner pointer.
    %
    props = libpointer('voidPtr');
    if ~isempty(initData.properties_)
        if ~isa(initData.properties_, 'Ice.Properties')
            throw(MException('Ice:ArgumentException', 'invalid value for properties_ member'));
        else
            props = initData.properties_.impl_;
        end
    end

    impl = libpointer('voidPtr');
    args = IceInternal.Util.callWithResult('Ice_initialize', args, props, impl);
    communicator = Ice.Communicator(impl, initData);
end