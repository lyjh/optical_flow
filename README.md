Author: Tse-Chi Wang (tsechiw@umich.edu)

This is a tracking algorithm based on optical flow.

1. Calculating optical flow for a frame sequence

There are two ways to calculate otical flow:

calculateFlow(title) or calculateFlow2(title),

where title is the name of the frame sequence. All sequences are downloadded from
https://sites.google.com/site/trackerbenchmark/benchmarks/v10

The first method is slower but more accurate,
while the second one is faster but slightly inaccurate.

2. Viewing the result of optical flow

Using function viewFlow(title, flag) can visualize the flow of the sequence.
If the flow is calculated by calculateFlow(), then set flag = 1,
otherwise set flag = 2.

3. Doing the tracking
