#ifndef FDA_METRICS_H_
#define FDA_METRICS_H_

#include <dlib/dnn/layers.h>
#include <dlib/image_processing.h>
#include <dlib/dnn.h>


namespace dlib
{
// ----------------------------------------------------------------------------------------

	class fda_test_box_overlap
	{
	public:
		fda_test_box_overlap() : iou_thresh(0.5), percent_covered_thresh(1.0)
		{}

		explicit fda_test_box_overlap(
			double iou_thresh_,
			double percent_covered_thresh_ = 1.0
		) : iou_thresh(iou_thresh_), percent_covered_thresh(percent_covered_thresh_)
		{
			// make sure requires clause is not broken
			DLIB_ASSERT(0 <= iou_thresh && iou_thresh <= 1 &&
				0 <= percent_covered_thresh && percent_covered_thresh <= 1,
				"\t vace::test_box_overlap::vace::test_box_overlap(iou_thresh, percent_covered_thresh)"
				<< "\n\t Invalid inputs were given to this function "
				<< "\n\t iou_thresh:   " << iou_thresh
				<< "\n\t percent_covered_thresh: " << percent_covered_thresh
				<< "\n\t this: " << this
			);

		}

		bool operator() (
			const dlib::rectangle& a,
			const dlib::rectangle& b
			) const
		{
			const double inner = a.intersect(b).area();
			if (inner == 0)
				return false;

			//const double outer = (a+b).area();
			const double outer = a.area() + b.area() - inner;

			if (inner / outer > iou_thresh ||
				inner / a.area() > percent_covered_thresh ||
				inner / b.area() > percent_covered_thresh)
				return true;
			else
				return false;
		}

		double get_percent_covered_thresh(
		) const
		{
			return percent_covered_thresh;
		}

		double get_iou_thresh(
		) const
		{
			return iou_thresh;
		}

	private:
		double iou_thresh;
		double percent_covered_thresh;

	};	// end of class fda_test_box_overlap

// ----------------------------------------------------------------------------------------

	inline bool fda_overlaps_any_box(
		const fda_test_box_overlap& tester,
		const std::vector<rectangle>& rects,
		const rectangle& rect
	)
	{
		for (unsigned long i = 0; i < rects.size(); ++i)
		{
			if (tester(rects[i], rect))
				return true;
		}
		return false;
	}
// ----------------------------------------------------------------------------------------

    namespace fda
    {
        inline unsigned long fda_number_of_truth_hits (
            const std::vector<full_object_detection>& ground_truth_boxes,
            const std::vector<rectangle>& ignore,
            const std::vector<std::pair<double,rectangle> >& boxes,
            const fda_test_box_overlap& overlap_tester,
            std::vector<std::pair<double,bool> >& all_dets,
            unsigned long& missing_detections
            //const fda_test_box_overlap& overlaps_ignore_tester 
        )
        /*!
            ensures
                - returns the number of elements in ground_truth_boxes which are overlapped by an 
                  element of boxes.  In this context, two boxes, A and B, overlap if and only if
                  overlap_tester(A,B) == true.
                - No element of boxes is allowed to account for more than one element of ground_truth_boxes.  
                - The returned number is in the range [0,ground_truth_boxes.size()]
                - Adds the score for each box from boxes into all_dets and labels each with
                  a bool indicating if it hit a truth box.  Note that we skip boxes that
                  don't hit any truth boxes and match an ignore box.
                - Adds the number of truth boxes which didn't have any hits into
                  missing_detections.
        !*/
        {
            if (boxes.size() == 0)
            {
                missing_detections += ground_truth_boxes.size();
                return 0;
            }

            unsigned long count = 0;
            std::vector<bool> used(boxes.size(),false);
            for (unsigned long i = 0; i < ground_truth_boxes.size(); ++i)
            {
                bool found_match = false;
                // Find the first box that hits ground_truth_boxes[i]
                for (unsigned long j = 0; j < boxes.size(); ++j)
                {
                    if (used[j])
                        continue;

                    if (overlap_tester(ground_truth_boxes[i].get_rect(), boxes[j].second))
                    {
                        used[j] = true;
                        ++count;
                        found_match = true;
                        break;
                    }
                }

                if (!found_match)
                    ++missing_detections;
            }

            for (unsigned long i = 0; i < boxes.size(); ++i)
            {
                // only out put boxes if they match a truth box or are not ignored.
                if (used[i] || !fda_overlaps_any_box(overlap_tester, ignore, boxes[i].second))
                {
                    all_dets.push_back(std::make_pair(boxes[i].first, used[i]));
                }
            }

            return count;
        }

        // inline unsigned long number_of_truth_hits (
            // const std::vector<full_object_detection>& truth_boxes,
            // const std::vector<rectangle>& ignore,
            // const std::vector<std::pair<double,rectangle> >& boxes,
            // const test_box_overlap& overlap_tester,
            // std::vector<std::pair<double,bool> >& all_dets,
            // unsigned long& missing_detections
        // )
        // {
            // return number_of_truth_hits(truth_boxes, ignore, boxes, overlap_tester, all_dets, missing_detections, overlap_tester);
        // }

    // ------------------------------------------------------------------------------------

    }	// end of fda namespace
	
	
// ----------------------------------------------------------------------------------------

    template <
        typename object_detector_type,
        typename array_type
        >
    const matrix<double,1,7> fda_object_detection_metrics (
        object_detector_type& detector,
        array_type& images,
        std::vector<std::vector<mmod_rect>>& truth_dets,
		const unsigned int min_det_size
        //const std::vector<std::vector<rectangle> >& ignore,
        //const fda_test_box_overlap& overlap_tester = test_box_overlap(),
        //const double adjust_threshold = 0
    )
    {	
	
		unsigned long img_count = images.size();
		// make sure requires clause is not broken
		DLIB_CASSERT(is_learning_problem(images, truth_dets) == true,
			"\t matrix test_object_detection_function()"
			<< "\n\t invalid inputs were given to this function"
			<< "\n\t is_learning_problem(images,truth_dets): " << is_learning_problem(images, truth_dets)
			<< "\n\t images.size(): " << img_count
		);	
	
		unsigned long idx, jdx;

		std::vector<unsigned long> Ng(img_count, 0);		// container to hold the number of ground truth boxes
		std::vector<unsigned long> Nd(img_count, 0);		// container to hold the number of detection boxes found
		std::vector<unsigned long> FApF(img_count, 0);
		std::vector<unsigned long> Cor_Dets(img_count, 0);
		std::vector<double> FDA(img_count, 0);
		std::vector<std::pair<double, bool>> all_dets;

		double SFDA_num = 0;
		double SFDA_denom = 0;
		unsigned char scale = 1;	// number of times to double the image size
		unsigned long missing_detections = 0;
		unsigned long false_positives = 0;
		unsigned long correct_hits = 0;
		unsigned long Ng_sum = 0;
		unsigned long Nd_sum = 0;

		// Now lets run the detector on the testing images and look at the outputs.  
		pyramid_down<2> pyr_up;

		for (idx = 0; idx < img_count; idx++)
		{
						
			std::vector<full_object_detection> truth_boxes;
			std::vector<full_object_detection> small_truth_boxes;

			std::vector<dlib::rectangle> ignore;
			std::vector<std::pair<double, dlib::rectangle>> boxes;			
					
			// double the size of the image for every loop also scale up the rects 
			//for (jdx = 0; jdx < scale; jdx++)
			//{
			//	dlib::pyramid_up(images[idx]);
			//}

			std::vector<mmod_rect> dets = detector(images[idx]);

			for (jdx = 0; jdx < truth_dets[idx].size(); jdx++)
			{
				truth_dets[idx][jdx].rect = pyr_up.rect_up(truth_dets[idx][jdx].rect);

				// copy truth_dets into the correct object
				if (truth_dets[idx][jdx].ignore)
				{
					ignore.push_back(truth_dets[idx][jdx].rect);
				}
				else if ((truth_dets[idx][jdx].rect.width() < min_det_size) || (truth_dets[idx][jdx].rect.height() < min_det_size))
				{
					small_truth_boxes.push_back(full_object_detection(truth_dets[idx][jdx].rect));
				}
				else
				{
					truth_boxes.push_back(full_object_detection(truth_dets[idx][jdx].rect));
				}
			}

			for (jdx = 0; jdx < dets.size(); jdx++)
			{
				boxes.push_back(std::make_pair(dets[jdx].detection_confidence, dets[jdx].rect));
			}


			const fda_test_box_overlap& overlap_tester = fda_test_box_overlap(0.3, 1.0);
			Cor_Dets[idx] = fda::fda_number_of_truth_hits(truth_boxes, ignore, boxes, overlap_tester, all_dets, missing_detections);
			unsigned long small_dets_count = fda::fda_number_of_truth_hits(small_truth_boxes, ignore, boxes, overlap_tester, all_dets, missing_detections);

			Cor_Dets[idx] += small_dets_count;
			correct_hits += Cor_Dets[idx];

			Ng[idx] = truth_boxes.size() + small_dets_count;				// number of ground truth images that are not ignored
			Nd[idx] = dets.size();											// number of detections
			Ng_sum += Ng[idx];
			Nd_sum += Nd[idx];


			FApF[idx] = Nd[idx] - Cor_Dets[idx];
			false_positives += FApF[idx];

			if ((Ng[idx] != 0) || (Nd[idx] != 0))
			{
				FDA[idx] = (double)Cor_Dets[idx] / ((double)(Ng[idx] + Nd[idx]) / 2.0);
				SFDA_num += FDA[idx];
				SFDA_denom++;
			}

		}	// end of image for loop

		// calculate the SFDA
		double SFDA = SFDA_num / ((double)SFDA_denom);

		matrix<double, 1, 7> res;
		res = SFDA, SFDA_num, SFDA_denom, (double)Ng_sum, (double)Nd_sum, (double)correct_hits, (double)false_positives;
		return res;
	
	}	// end of fda_object_detection_metrics	
	
}	// end of dlib namespace

#endif 	// FDA_METRICS_H_
