// lib/data/policy_data.dart

import 'package:flutter/material.dart';
import '../models/policy_model.dart';

class PolicyData {
  static const List<PolicyModel> policies = [
    PolicyModel(
      id: 'odd_even',
      name: 'Odd-Even Rule',
      shortDescription: 'Vehicles allowed on alternate days by plate number',
      icon: Icons.directions_car,
      kBase: 0.005,
      sourceBreakdown: {
        'transport': 35,
        'industry': 25,
        'dust': 20,
        'others': 20,
      },
      sourceImpact: {
        'transport': 40,
        'industry': 0,
        'dust': 0,
        'others': 0,
      },
      primaryContributor: 'Vehicular emission reduction',
      secondaryEffect: 'Lower NO₂ leading to reduced secondary PM2.5 formation',
      affectedSourceTag: 'Traffic',
      tagColor: Color(0xFFEF4444),
    ),

    PolicyModel(
      id: 'work_from_home',
      name: 'Work From Home',
      shortDescription: '50% of offices shift to remote work mandate',
      icon: Icons.house_outlined,
      kBase: 0.007,
      sourceBreakdown: {
        'transport': 35,
        'industry': 25,
        'dust': 20,
        'others': 20,
      },
      sourceImpact: {
        'transport': 30,
        'industry': 5,
        'dust': 0,
        'others': 10,
      },
      primaryContributor: 'Reduced peak-hour commuter traffic',
      secondaryEffect: 'Lower CO levels improve O₃ formation cycle',
      affectedSourceTag: 'Traffic',
      tagColor: Color(0xFFF59E0B),
    ),

    PolicyModel(
      id: 'construction_ban',
      name: 'Construction Ban',
      shortDescription: 'Halt of all non-essential construction activity',
      icon: Icons.block,
      kBase: 0.006,
      sourceBreakdown: {
        'transport': 35,
        'industry': 25,
        'dust': 20,
        'others': 20,
      },
      sourceImpact: {
        'transport': 0,
        'industry': 0,
        'dust': 60,
        'others': 5,
      },
      primaryContributor: 'Suspended particulate dust from construction sites',
      secondaryEffect: 'PM10 drop reduces coarse particle loading in air',
      affectedSourceTag: 'Dust',
      tagColor: Color(0xFF78716C),
    ),

    PolicyModel(
      id: 'industrial_control',
      name: 'Industrial Control',
      shortDescription: 'Emission caps and partial shutdown of heavy industry',
      icon: Icons.factory,
      kBase: 0.010,
      sourceBreakdown: {
        'transport': 35,
        'industry': 25,
        'dust': 20,
        'others': 20,
      },
      sourceImpact: {
        'transport': 0,
        'industry': 60,
        'dust': 10,
        'others': 5,
      },
      primaryContributor: 'Industrial SO₂ and NOₓ emission reduction',
      secondaryEffect: 'Lower SO₂ reduces sulfate aerosol and acid deposition',
      affectedSourceTag: 'Industry',
      tagColor: Color(0xFF6366F1),
    ),

    PolicyModel(
      id: 'public_transport_boost',
      name: 'Public Transport Boost',
      shortDescription: 'Free & expanded bus/metro service to reduce private vehicles',
      icon: Icons.directions_bus,
      kBase: 0.006,
      sourceBreakdown: {
        'transport': 35,
        'industry': 25,
        'dust': 20,
        'others': 20,
      },
      sourceImpact: {
        'transport': 25,
        'industry': 0,
        'dust': 5,
        'others': 5,
      },
      primaryContributor: 'Modal shift from private vehicles to public transport',
      secondaryEffect: 'Reduced road dust re-suspension from lower traffic volume',
      affectedSourceTag: 'Traffic',
      tagColor: Color(0xFF0F766E),
    ),
  ];

  static PolicyModel getById(String id) =>
      policies.firstWhere((p) => p.id == id);
}