function B = imguidedfilter(varargin)
%IMGUIDEDFILTER Guided filtering of images
%
%   B = imguidedfilter(A, G) filters binary, grayscale, or RGB image A
%   using the guided filter, where the filtering process is guided by image
%   G. G can be a binary, grayscale or RGB image and must have the same
%   number of rows and columns as A.
%
%   B = imguidedfilter(A) filters input image A under self-guidance i.e.,
%   using A itself as the guidance image. This can be used for
%   edge-preserving smoothing of image A.
%
%   B = imguidedfilter(__,Name,Value,...) filters the image A using name-value
%   pairs to control aspects of guided filtering. Parameter names can be
%   abbreviated.
%
%   Parameters include:
%
%   'NeighborhoodSize' -  Scalar (Q) or two-element vector, [M N], of
%                         positive integers that specifies the size of the
%                         rectangular neighborhood around each pixel used
%                         in guided filtering. If a scalar Q is specified,
%                         then the square neighborhood of size [Q Q] is
%                         used. Specified value cannot be greater than the
%                         size of the image.
%                         Default value is [5 5].
%
%   'DegreeOfSmoothing' - Positive scalar that controls the amount of
%                         smoothing in the output image. Small value for
%                         this parameters means that only neighborhoods
%                         with small variance (uniform areas) will get
%                         smoothed and the neighborhoods with larger
%                         variance (such as around edges) will not be
%                         smoothed. Larger values for this parameter will
%                         allow smoothing of higher variance neighborhoods,
%                         such as stronger edges, in addition to the
%                         relatively uniform neighborhoods.
%                         Default value is 0.01*diff(getrangefromclass(G)).^2.
%
%   Class Support
%   -------------
%   The input arrays A and G must be of one of the following classes:
%   logical, uint8, int8, uint16, int16, uint32, int32, single, or double.
%   They must be nonsparse. Output image B is an array of the same size and
%   type as A.
%
%   Notes
%   -----
%   1. The parameter 'DegreeOfSmoothing' specifies a soft threshold on
%      variance for the given neighborhood. If a pixel's neighborhood has
%      variance much lower than the threshold, it will see some amount of
%      smoothing. If a pixel's neighborhood has variance much higher than
%      the threshold it will have little to no smoothing.
%
%   2. Input images A and G can be of different classes. If either A or G
%      are of class integer, single, or logical, they are converted to
%      double precision floating-point for internal computation.
%
%   3. If A is RGB and G is grayscale or binary, then G is used for
%      guidance for all the channels of A independently. If both A and G
%      are RGB images, each channel of G is used for guidance for the
%      corresponding channel of A, i.e. plane-by-plane behavior. If A is
%      grayscale or binary and G is RGB, all the three channels of G are
%      used for guidance (color statistics) for filtering A.
%
%
%   Example 1
%   ---------
%   This example does edge-preserving smoothing on an example image using
%   the guided filter.
%
%     A = imread('pout.tif');
%
%     Ismooth = imguidedfilter(A);
%
%     imshowpair(A, Ismooth, 'montage');
%
%   Example 2
%   ---------
%   This example does flash-noflash denoising using the guided filter
%
%     A = imread('toysnoflash.png');
%     G = imread('toysflash.png');
%
%     nhoodSize = 3;
%     smoothValue  = 0.001*diff(getrangefromclass(G)).^2;
%
%     B = imguidedfilter(A, G, 'NeighborhoodSize', nhoodSize, 'DegreeOfSmoothing',smoothValue);
%
%     figure, imshow(A), title('Input Image - Camera Flash Off')
%     figure, imshow(G), title('Guidance Image - Camera Flash On')
%     figure, imshow(B), title('Filtered Image')
%
%     % Show zoomed in region
%     figure;
%     h1 = subplot(1,2,1);
%     imshow(A), title('Region in Original Image'), axis on
%     h2 = subplot(1,2,2);
%     imshow(B), title('Region in Filtered Image'), axis on
%     linkaxes([h1 h2])
%     xlim([520 660])
%     ylim([150 250])
%
%   References:
%   -----------
%   [1] Kaiming He, Jian Sun, Xiaou Tang, "Guided Image Filtering," IEEE
%       Transactions on Pattern Analysis and Machine Intelligence, Volume
%       35, Issue 6, pp. 1397-1409, June 2013.
%
%   See also EDGE, IMFILTER, IMSHARPEN.

%   Copyright 2013-2015 The MathWorks, Inc.

narginchk(1, 6);

[A, G, filtSize, inversionEpsilon] = parse_inputs(varargin{:});

if isempty(A)
    B = A;
    return;
end

B = images.internal.algimguidedfilter(A, G, filtSize, inversionEpsilon);

end

function [A, G, filtSize, inversionEpsilon] = parse_inputs(varargin)

parser = inputParser();

p.CaseSensitive = false;
p.PartialMatching = true;

validImageTypes = {'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32', ...
    'single', 'double', 'logical'};

parser.addRequired('A', @checkA);
parser.addOptional('G', [], @checkG);

parser.addParameter('NeighborhoodSize', [5, 5], @checkNeighborhoodSize);
parser.addParameter('DegreeOfSmoothing', [], @checkDegreeOfSmoothing);

parser.parse(varargin{:});
parsedInputs = parser.Results;

if isempty(parsedInputs.G)
    parsedInputs.G = parsedInputs.A;
else
    validateInputImages();
end

if length(parsedInputs.NeighborhoodSize) == 1
    parsedInputs.NeighborhoodSize = ...
        [parsedInputs.NeighborhoodSize, parsedInputs.NeighborhoodSize];
end
validateNeighborhoodSize();

if isempty(parsedInputs.DegreeOfSmoothing)
    parsedInputs.DegreeOfSmoothing = ...
        0.01 * diff(getrangefromclass(parsedInputs.G)).^2;
else
    parsedInputs.DegreeOfSmoothing = double(parsedInputs.DegreeOfSmoothing);
end

A = parsedInputs.A;
G = parsedInputs.G;
filtSize = parsedInputs.NeighborhoodSize;
inversionEpsilon = parsedInputs.DegreeOfSmoothing;


    function validateInputImages

        sizeA = [size(parsedInputs.A), 1];
        sizeG = [size(parsedInputs.G), 1];

        if ~isequal(sizeA(1:2), sizeG(1:2))
            error(message('images:imguidedfilter:unequalImageSizes', 'A', 'G'));
        end

        if (sizeA(3) ~= sizeG(3))
            if (sizeA(3) ~= 1 && sizeA(3) ~= 3)
                error(message('images:imguidedfilter:wrongNumberOfChannels', ...
                    'A', 'G', 'A'));
            end
            if (sizeG(3) ~= 1 && sizeG(3) ~= 3)
                error(message('images:imguidedfilter:wrongNumberOfChannels', ...
                    'G', 'A', 'G'));
            end
        end

    end

    function validateNeighborhoodSize
        % If user has specified NeighborhoodSize, i.e. default
        % NeighborhoodSize is not used and if the specified value is too
        % big, then throw an error.
        if (~any(strcmp('NeighborhoodSize', parser.UsingDefaults))) && ...
                (any(parsedInputs.NeighborhoodSize > [size(parsedInputs.A, 1), ...
                size(parsedInputs.A, 2)]))
            error(message('images:imguidedfilter:nhoodSizeTooLarge', ...
                'NeighborhoodSize'));
        end
    end

    function tf = checkA(A)

        validateattributes(A, validImageTypes, {'3d', 'nonsparse', 'real'}, ...
            mfilename, 'A', 1);

        tf = true;

    end

    function tf = checkG(G)

        validateattributes(G, validImageTypes, {'3d', 'nonsparse', 'real'}, ...
            mfilename, 'G', 2);

        tf = true;

    end

    function tf = checkNeighborhoodSize(NeighborhoodSize)

        validateattributes(NeighborhoodSize, {'numeric'}, {'vector', ...
            'finite', 'nonsparse', 'nonempty', 'real', 'positive', 'integer'}, ...
            mfilename, 'NeighborhoodSize');

        if (numel(NeighborhoodSize) > 2)
            error(message('images:imguidedfilter:nhoodSizeVectTooLong', ...
                'NeighborhoodSize'));
        end

        tf = true;

    end

    function tf = checkDegreeOfSmoothing(DegreeOfSmoothing)

        validateattributes(DegreeOfSmoothing, {'numeric'}, {'positive', ...
            'finite', 'real', 'nonempty', 'scalar'}, mfilename, ...
            'DegreeOfSmoothing');

        tf = true;

    end

end
