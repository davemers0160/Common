#ifndef ROTATE_90_H_
#define ROTATE_90_H_

#include "dlib/matrix.h"
//#include "dlib/matrix/matrix_expressions.h"
//#include "dlib/matrix/matrix_mat.h"
//#include "dlib/matrix/matrix_op.h"
//#include "dlib/matrix/matrix_exp.h"

// ----------------------------------------------------------------------------------------

template <typename array_type>
const array_type rotate_90(
    array_type& m,
    uint64_t d = 1)
{

    //typedef typename matrix_exp<EXP>::type type;
    array_type val;

    // bound the rotation 
    d = d % 4;

    switch (d)
    {
    case 1:
        val = dlib::trans(dlib::fliplr(m));
        break;

    case 2:
        val = dlib::flip(m);
        break;

    case 3:
        val = dlib::fliplr(dlib::trans(m));
        break;

    default:
        val = m;
        break;
    }

    return val;

}   // end of rotate_90



#endif  // end of ROTATE_90_H_
