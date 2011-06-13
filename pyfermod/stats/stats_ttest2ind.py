"""
Performs a two-sided T-test that two independent samples
come from (normal) distributions with the same mean.
"""
import numpy
import pyferret
import scipy.stats


def ferret_init(id):
    """
    Initialization for the stats_ttest2ind PyEF
    """
    retdict = { "numargs": 2,
                "descript": "Returns two-sided T-test stat. and prob. that two independent " \
                            "samples comes from (normal) distribs. with the same mean",
                "axes": ( pyferret.AXIS_CUSTOM,
                          pyferret.AXIS_DOES_NOT_EXIST,
                          pyferret.AXIS_DOES_NOT_EXIST,
                          pyferret.AXIS_DOES_NOT_EXIST, ),
                "argnames": ( "SAMPLEA", "SAMPLEB", ),
                "argdescripts": ( "First sample data array",
                                  "Second sample data array", ),
                "argtypes": ( pyferret.FLOAT_ARG, pyferret.FLOAT_ARG, ),
                "influences": ( (False, False, False, False),
                                (False, False, False, False), ),
              }
    return retdict


def ferret_custom_axes(id):
    """
    Define custom axis of the stats_ttest2ind Ferret PyEF
    """
    return ( ( 1, 2, 1, "T,P", False ), None, None, None, )


def ferret_compute(id, result, resbdf, inputs, inpbdfs):
    """
    Performs a two-sided T-test that two independent samples come from
    (normal) distributions with the same mean.  The samples are given
    in inputs[0] and inputs[1].  The test statistic value and two-tailed
    probability are returned in result.  Undefined data given in each
    sample are removed (independently from each other) before performing
    the test.  Note that the samples do not need to be the same size;
    thus there are no restrictions on the relative dimensions of sample
    arrays.
    """
    badmask = ( numpy.fabs(inputs[0] - inpbdfs[0]) < 1.0E-5 )
    badmask = numpy.logical_or(badmask, numpy.isnan(inputs[0]))
    goodmask = numpy.logical_not(badmask)
    sampa = inputs[0][goodmask]
    badmask = ( numpy.fabs(inputs[1] - inpbdfs[1]) < 1.0E-5 )
    badmask = numpy.logical_or(badmask, numpy.isnan(inputs[1]))
    goodmask = numpy.logical_not(badmask)
    sampb = inputs[1][goodmask]
    fitparams = scipy.stats.ttest_ind(sampa, sampb)
    result[:, :, :, :] = resbdf
    # T-test statistic
    result[0, 0, 0, 0] = fitparams[0]
    # probability
    result[1, 0, 0, 0] = fitparams[1]


#
# The rest of this is just for testing this module at the command line
#
if __name__ == "__main__":
    # make sure ferret_init and ferret_custom_axes do not have problems
    info = ferret_init(0)
    info = ferret_custom_axes(0)

    # Get random samples from normal distribution
    # with the same mean and with a different mean
    ydima = 250
    zdima = 150
    sampa = scipy.stats.norm(5.0,2.0).rvs(ydima * zdima)
    ydimb = 175
    zdimb = 75
    sampb = scipy.stats.norm(5.0,0.5).rvs(ydimb * zdimb)
    sampu = scipy.stats.norm(5.5,0.5).rvs(ydimb * zdimb)

    # setup for the call to ferret_compute
    inpbdfs = numpy.array([-9999.0, -8888.0], dtype=numpy.float32)
    resbdf = numpy.array([-7777.0], dtype=numpy.float32)
    arraya = numpy.empty((1, ydima, zdima, 1), dtype=numpy.float32, order='F')
    arrayb = numpy.empty((ydimb, 1, 1, zdimb), dtype=numpy.float32, order='F')
    arrayu = numpy.empty((ydimb, 1, 1, zdimb), dtype=numpy.float32, order='F')
    index = 0
    for j in xrange(ydima):
        for k in xrange(zdima):
            if (index % 23) == 3:
                arraya[0, j, k, 0] = inpbdfs[0]
            else:
                arraya[0, j, k, 0] = sampa[index]
            index += 1
    index = 0
    for j in xrange(ydimb):
        for k in xrange(zdimb):
            if (index % 53) == 3:
                arrayb[j, 0, 0, k] = inpbdfs[1]
                arrayu[j, 0, 0, k] = inpbdfs[1]
            else:
                arrayb[j, 0, 0, k] = sampb[index]
                arrayu[j, 0, 0, k] = sampu[index]
            index += 1
    resultb = -6666.0 * numpy.ones((2, 1, 1, 1), dtype=numpy.float32, order='F')
    resultu = -6666.0 * numpy.ones((2, 1, 1, 1), dtype=numpy.float32, order='F')

    # call ferret_compute with the samples from distribs with the same mean and check
    ferret_compute(0, resultb, resbdf, (arraya, arrayb), inpbdfs)
    resultb = resultb.reshape(-1)
    print "from same mean result: %s" % str(resultb)
    if (abs(resultb[0]) > 2.0) or \
       (resultb[1] <  0.1) or (resultb[1] > 1.0):
        raise ValueError("Unexpected result")

    # call ferret_compute with the samples from distribs with different means and check
    ferret_compute(0, resultu, resbdf, (arraya, arrayu), inpbdfs)
    resultu = resultu.reshape(-1)
    print "from diff mean result: %s" % str(resultu)
    if (resultu[0] > -20.0) or \
       (resultu[1] < 0.0) or (resultu[1] > 1.0E-5):
        raise ValueError("Unexpected result")

    # All successful
    print "Success"

