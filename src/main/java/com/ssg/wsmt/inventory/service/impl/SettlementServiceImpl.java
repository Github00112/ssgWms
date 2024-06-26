package com.ssg.wsmt.inventory.service.impl;

import com.ssg.wsmt.inventory.dao.SettlementDao;
import com.ssg.wsmt.inventory.domain.SettlementVO;
import com.ssg.wsmt.inventory.dto.PageRequestDTO;
import com.ssg.wsmt.inventory.dto.PageResponseDTO;
import com.ssg.wsmt.inventory.dto.SettlementChartDTO;
import com.ssg.wsmt.inventory.dto.SettlementDTO;
import com.ssg.wsmt.inventory.mapper.SettlementMapper;
import com.ssg.wsmt.inventory.service.SettlementService;
import com.ssg.wsmt.smOrders.dto.SmOrdersDTO;
import com.ssg.wsmt.smOrders.enums.SellerSendStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


@Log4j2
@Service
@RequiredArgsConstructor
public class SettlementServiceImpl implements SettlementService {

    private final SettlementMapper settlementMapper;

    @Override
    public PageResponseDTO<SettlementDTO> ReadAllSetlist(PageRequestDTO pageRequestDTO) {
        int offset = pageRequestDTO.getOffset();
        int size = pageRequestDTO.getSize();

        List<SettlementDTO> dtoList = settlementMapper.searchSetAll(pageRequestDTO.getTypes(), pageRequestDTO.getKeyword(), offset, size);
        int totalCount = settlementMapper.getSetTotalCount(pageRequestDTO.getTypes(), pageRequestDTO.getKeyword());

        return PageResponseDTO.<SettlementDTO>withAll()
                .dtoList(dtoList)
                .pageRequestDTO(pageRequestDTO)
//                .page(pageRequestDTO.getPage()) // 페이지 정보 설정
//                .size(pageRequestDTO.getSize()) // 페이지 크기 설정
                .total(totalCount) // 전체 항목 수 설정
                .build();
    }

    @Override
    public List<SettlementChartDTO> getChartData() {
        return settlementMapper.getChartData();
    }



    @Override
    public List<SettlementDTO> searchSet(Long settlementId) {
        return settlementMapper.findSetByCriteria(settlementId);
    }
//    다혜가 함요!!

//    @Override
//    public List<SettlementDTO> settlementList() {
//        List<SettlementDTO> dtoList = settlementMapper.selectAll().stream()
//                .map(vo -> SettlementDTO.builder()
//                        .id(vo.getId())
//                        .insertQuantity(vo.getInsertQuantity())
//                        .releaseQuantity(vo.getReleaseQuantity())
//                        .totalPrice(vo.getTotalPrice())
//                        .createdAt(vo.getCreatedAt())
//                        .modifiedAt(vo.getModifiedAt())
//                        .build()
//                ).collect(Collectors.toList());
//        log.info(dtoList);
//        return dtoList;
//    }

    @Override
    public List<SettlementDTO> setDateList(LocalDate startDate, LocalDate endDate) {
        return settlementMapper.selectSetDate(startDate, endDate);
    }




}


    /* 1차 프로젝트
    // private SettlementDao settlementDao = new SettlementDao();

    @Override
    public void settlementList() {
        System.out.println("정산 리스트 출력");
        Optional<List<SettlementVO>> settlementList = settlementDao.settlementList();

        if (settlementList.isEmpty()) {
            System.out.println("정산 리스트가 존재하지 않습니다.");
            return;
        }

        for (SettlementVO settlement : settlementList.get()) {
            System.out.println(settlement);
        }
    }

    @Override
    public void settlementByDate() {
        System.out.println("특정 날짜 정산 출력");
        System.out.print("찾고 싶은 정산 날짜를 입력하세요.(날짜 입력 방식 2024-02-02) : ");
        String date = null;
        try {
            date = br.readLine();
        } catch (Exception e) {
            e.printStackTrace();
        }
        Optional<SettlementVO> settlement = settlementDao.settlementByDate(date);

        if (settlement == null) {
            System.out.println("해당 날짜의 정산이 존재하지 않습니다.");
            return;
        }
        System.out.println(settlement.get());
    }
    }

     */