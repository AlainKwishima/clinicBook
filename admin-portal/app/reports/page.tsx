'use client'

import { createClient } from '@/utils/supabase/client'
import Link from 'next/link'
import { ChevronLeft, BarChart3, TrendingUp, Users, Calendar, ArrowUpRight, ArrowDownRight } from 'lucide-react'
import { useEffect, useState } from 'react'

export default function ReportsPage() {
    const [stats, setStats] = useState({
        totalDoctors: 0,
        activePatients: 0,
        appointmentsToday: 0,
        revenue: 0
    })

    const supabase = createClient()

    useEffect(() => {
        // Simulate fetching stats or fetch real counts
        async function fetchStats() {
            const { count: doctorCount } = await supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'doctor')
            const { count: patientCount } = await supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'patient')

            setStats({
                totalDoctors: doctorCount || 12,
                activePatients: patientCount || 145,
                appointmentsToday: 24, // Mock for now
                revenue: 12500 // Mock
            })
        }
        fetchStats()
    }, [])

    return (
        <div className="min-h-screen bg-gray-50/50 p-6 sm:p-10">
            <div className="mx-auto max-w-7xl">

                {/* Header */}
                <div className="mb-8 flex items-center justify-between">
                    <div className="flex items-center gap-4">
                        <Link href="/" className="rounded-full bg-white p-2.5 text-gray-500 shadow-sm transition hover:bg-gray-100 hover:text-gray-700">
                            <ChevronLeft className="h-5 w-5" />
                        </Link>
                        <div>
                            <h1 className="text-3xl font-bold text-gray-900">Analytics & Reports</h1>
                            <p className="mt-1 text-sm text-gray-500">Overview of clinic performance and activities</p>
                        </div>
                    </div>
                    <div className="flex items-center gap-3">
                        <span className="text-sm font-medium text-gray-500">Last 30 Days</span>
                        <button className="inline-flex items-center rounded-lg bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm border border-gray-200 hover:bg-gray-50">
                            <Calendar className="mr-2 h-4 w-4 text-gray-400" />
                            Export CSV
                        </button>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4 mb-8">
                    {[
                        { label: 'Total Revenue', value: '$12,500', change: '+12.5%', trend: 'up', icon: TrendingUp, color: 'text-green-600', bg: 'bg-green-100' },
                        { label: 'Total Doctors', value: stats.totalDoctors, change: '+2', trend: 'up', icon: Users, color: 'text-blue-600', bg: 'bg-blue-100' },
                        { label: 'Appointments', value: '432', change: '+18%', trend: 'up', icon: Calendar, color: 'text-purple-600', bg: 'bg-purple-100' },
                        { label: 'Avg Wait Time', value: '14m', change: '-2.4%', trend: 'down', icon: BarChart3, color: 'text-orange-600', bg: 'bg-orange-100' },
                    ].map((stat, i) => (
                        <div key={i} className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm transition hover:shadow-md">
                            <div className="flex items-center justify-between">
                                <div className={`rounded-lg p-3 ${stat.bg}`}>
                                    <stat.icon className={`h-6 w-6 ${stat.color}`} />
                                </div>
                                <div className={`flex items-center text-sm font-medium ${stat.trend === 'up' ? 'text-green-600' : 'text-red-600'}`}>
                                    {stat.change}
                                    {stat.trend === 'up' ? <ArrowUpRight className="ml-1 h-4 w-4" /> : <ArrowDownRight className="ml-1 h-4 w-4" />}
                                </div>
                            </div>
                            <div className="mt-4">
                                <h3 className="text-sm font-medium text-gray-500">{stat.label}</h3>
                                <p className="mt-2 text-3xl font-bold text-gray-900">{stat.value}</p>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Charts Section (Placeholder visuals) */}
                <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">

                    {/* Revenue Chart */}
                    <div className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
                        <h3 className="text-lg font-bold text-gray-900 mb-6">Revenue Overview</h3>
                        <div className="h-64 flex items-end justify-between gap-2 px-2">
                            {[40, 65, 45, 78, 52, 89, 70, 85, 92, 60, 75, 95].map((h, i) => (
                                <div key={i} className="w-full bg-blue-50 rounded-t-sm relative group">
                                    <div
                                        className="absolute bottom-0 w-full bg-blue-500 rounded-t-sm transition-all duration-500 group-hover:bg-blue-600"
                                        style={{ height: `${h}%` }}
                                    ></div>
                                </div>
                            ))}
                        </div>
                        <div className="mt-4 flex justify-between text-xs text-gray-400 font-medium uppercase">
                            <span>Jan</span><span>Feb</span><span>Mar</span><span>Apr</span><span>May</span><span>Jun</span>
                            <span>Jul</span><span>Aug</span><span>Sep</span><span>Oct</span><span>Nov</span><span>Dec</span>
                        </div>
                    </div>

                    {/* Activity List */}
                    <div className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
                        <h3 className="text-lg font-bold text-gray-900 mb-6">Recent Activity</h3>
                        <div className="space-y-6">
                            {[
                                { name: 'Dr. John Doe', action: 'Approved new registration', time: '2 hours ago', icon: Users, bg: 'bg-green-100', color: 'text-green-600' },
                                { name: 'City Hospital', action: 'Updated facility details', time: '4 hours ago', icon: Calendar, bg: 'bg-blue-100', color: 'text-blue-600' },
                                { name: 'System', action: 'Weekly backup completed', time: '12 hours ago', icon: BarChart3, bg: 'bg-gray-100', color: 'text-gray-600' },
                                { name: 'Dr. Sarah Smith', action: 'Flagged for review', time: '1 day ago', icon: Users, bg: 'bg-red-100', color: 'text-red-600' },
                            ].map((item, i) => (
                                <div key={i} className="flex items-start gap-4">
                                    <div className={`rounded-full p-2 ${item.bg} mt-1`}>
                                        <item.icon className={`h-4 w-4 ${item.color}`} />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-gray-900">{item.action}</p>
                                        <p className="text-xs text-gray-500">{item.name} • {item.time}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                        <div className="mt-6 pt-6 border-t border-gray-100">
                            <button className="text-sm font-medium text-blue-600 hover:text-blue-700">View all activity &rarr;</button>
                        </div>
                    </div>

                </div>

            </div>
        </div>
    )
}
