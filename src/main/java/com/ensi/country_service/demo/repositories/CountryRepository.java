package com.ensi.country_service.demo.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ensi.country_service.demo.beans.Country;

public interface CountryRepository extends JpaRepository<Country,Integer> {

}