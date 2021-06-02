package com.spring.springbootmybatisproject.survey.controller;

import com.spring.springbootmybatisproject.SFV;
import com.spring.springbootmybatisproject.common.model.ResultVO;
import com.spring.springbootmybatisproject.survey.model.SurveyItemVO;
import com.spring.springbootmybatisproject.survey.model.SurveyResult;
import com.spring.springbootmybatisproject.survey.service.SurveyService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@Slf4j
@RequestMapping("/survey")
public class SurveyController {

    ResultVO result = new ResultVO();

    @Autowired
    private SurveyService surveyService;

    @GetMapping("/list")
    public String surveyListForm() {
        return "/survey/surveyList";
    }


    /* 설문 항목 가져오기 */
    @GetMapping("/listProc")
    @ResponseBody
    public List<SurveyItemVO> surveyList() {
        List<SurveyItemVO> surveyList = surveyService.getSurveyList();

        log.info("list size: " + surveyList.size());
        for (SurveyItemVO vo : surveyList) {
            log.info("controller surveyList" + vo);

        }
        return surveyList;
    }

    /* 설문 항목 저장*/
    @PostMapping("/saveListProc")
    @ResponseBody
    public ResultVO saveSurveyList(@RequestBody List<SurveyItemVO.ReqDTO> reqDTOList) {

        try {
            surveyService.saveSurveyList(reqDTOList);
            result.setResCode(SFV.INT_RES_CODE_OK);
            result.setResMsg(SFV.STRING_RES_CODE_OK);

        } catch (Exception e) {
            result.setResCode(SFV.INT_RES_CODE_FAIL);
            result.setResMsg(SFV.STRING_RES_CODE_FAIL);
        }

        return result;
    }

    @GetMapping("/surveyResults")
    public String surveyResultForm() {
        return "/survey/surveyResult";
    }

    @GetMapping("/surveyResultProc/{d3ChartDiv}")
    @ResponseBody
    public List<SurveyResult.barGraphDTO> surveyResults(@PathVariable(name = "d3ChartDiv") String d3ChartDiv) {
        List<SurveyResult.barGraphDTO> surveyResult = null;

        if (d3ChartDiv.equals("barGraph")) {
            surveyResult = surveyService.getMajorItemResult();
        }
        return surveyResult;
    }

}
